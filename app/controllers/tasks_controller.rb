class TasksController < ApplicationController
  def new
    redirect_to tasks_path
  end
  
  def create
    @task = Task.new(task_params)
    @reshowNewTaskForm = false
    if @task.save
      @task = nil;
      index()
      render :index
    else
      @reshowNewTaskForm = true
      index()
      render :index
    end
  end
  
  def show
    @task = Task.find(params[:id])
  end
  
  def index
    # Get the current list.
    verifyCurrentList()
    @lists = List.all
    @list = List.find(getCurrentListID())
    
    # Determine how to sort the tasks.
    sort = getSortFieldFromParams()
    @constrainedSort = (sort != Field::NONE)
    if sort == Field::NONE
      sort = Field::PRIORITY # Default sort.
    end
    sqlSort = getSQLForSort(sort)

    # Build the SQL statement and query for tasks.
    tasksQuery = Task.joins('LEFT JOIN categories ON tasks.category_id = categories.id').order(sqlSort).where(list_id: @list.id).where(deleted: false).select("tasks.*, categories.title as category_title")
    tasksQuery = checkConstraints(tasksQuery)
    @tasks = tasksQuery
    
    @showPriorityHeaders = (sort == Field::PRIORITY) && !(params[:priorityHeaders] == 'false')
    @showCategoryHeaders = (sort == Field::PRIORITY) && !(params[:categoryHeaders] == 'false')
    @showAllColumns = params[:columns] == 'all' || @constrainedList
  end

  def destroy
    @task = Task.find(params[:id])
    @task.deleted = true
    success = @task.save
    
    respond_to do |format|
        format.json { head (success ? :ok : :internal_server_error)}
    end
  end
  
  def complete
    @task = Task.find(params[:id])
    @task.done = params[:completed] ? true : false
    success = @task.save

    respond_to do |format|
      format.json { head (success ? :ok : :internal_server_error)}
    end
  end
  
  def clearCompleted
    Task.where(list_id: getCurrentListID(), done: true).update_all(deleted: true)
    success = true

    respond_to do |format|
      format.json { head (success ? :ok : :internal_server_error)}
    end
  end

  def upload
    # Read CSV from file.
    file_data = params[:csv]
    if file_data.respond_to?(:read)
      csv_text = file_data.read
    elsif file_data.respond_to?(:path)
      csv_text = File.read(file_data.path)
    else
      csv_text = nil
      logger.error "Unable to read text from uploaded file."
    end

    # Add tasks to database.
    @importCountSucceeded = 0
    @importCountFailed = 0
    require 'csv'
    if csv_text
      csv = CSV.parse(csv_text, :headers => true)
      csv.each do |row|
        importCSVRow row
      end
    else
      logger.error "Unable to read text from uploaded file."
    end
    
    redirect_to tasks_path, flash: {importCountSucceeded: @importCountSucceeded, importCountFailed: @importCountFailed}
  end
  
  private
  def task_params
    params.require(:task).permit().tap do |whitelisted|
      # Permit fields from the database list.
      Field.where("titleForForm is not null").each do |f|
        whitelisted[f.titleForForm] = params[:task][f.titleForForm]
      end
    end
  end
  
  def checkConstraints tasksQuery
    @constrainedList = false

    Field.all.each do |f|
      val = params[f.name]
      if val && f.isValid(val)
        # Convert value to integer if appropriate.
        if f.dataType == "integer" || f.field == Field::CATEGORY
          val = val.to_i
        end

        # Handle any special cases while creating the WHERE clause.
        if f.field == Field::CREATED
          created = Time.strptime(params[:created_at], "%F")
          tasksQuery = tasksQuery.where(created_at: (created.midnight..(created.midnight + 1.day - 1.second)))
        elsif f.field == Field::FREQUENCY
          tasksQuery = tasksQuery.where(frequency: val)
        else
          tasksQuery = tasksQuery.where(f.name => val)
        end

        if f.field == Field::CATEGORY
          @showCategoryHeaders = false # It's unnecessary to show category headers when we are constrained to one category.
        end
      end
    end

    return tasksQuery
  end

  def importCSVRow row
    task = Task.new

    # Extract each field from this row.
    Field.all.each do |f|
      rowValue = row[f.titleForCSV]
      if rowValue
        dbFieldName = f.name
        if f.dataType == "date" || f.dataType == "datetime"
          begin
            rowValue = Date.parse(rowValue)
          rescue
            logger.error "Couldn't parse a date while importing CSV."
            next;
          end
        elsif f.field == Field::CATEGORY
          rowValue = Category.find_or_create_by(title: rowValue).id
          dbFieldName = "category_id"
        end
        task[dbFieldName] = rowValue
      end
    end

    task.list_id = getCurrentListID()

    begin
      if task.save
        @importCountSucceeded += 1
      else
        @importCountFailed += 1
      end
    rescue
      @importCountFailed += 1
    end
  end

  def getSortFieldFromParams
    field = Field.getFieldFromString(params[:sort])
    if field == Field::STATUS
      # Sorting by this field not supported.
      field == Field::NONE
    end
    return field
  end

  def getSQLForSort sortField
    # Start by sorting with the field that was passed in.
    dbField = Field.getDBFieldFromField(sortField)
    sql = dbField.orderString

    # Add secondary sorts based on the sort order of the fields in the database.
    fields = Field.order("orderSort").where("orderSort is not null")
    fields.each do |f|
      if f.field != sortField
        sql += ", " + f.orderString
      end
    end
    return sql
  end

  def getCurrentListID
    return cookies['list_id'] ? cookies['list_id'] : 1;
  end

  def verifyCurrentList
    if List.count == 0
      list = List.new({title: 'First List'})
      if list.save
        cookies['list_id'] = list.id
      else
        logger.error "Couldn't save new default list to database."
      end
    else
      begin
        list = List.find(getCurrentListID())
      rescue ActiveRecord::RecordNotFound
        list = List.first # Default to the first list.
        cookies['list_id'] = list.id
      end
    end
  end

  def shouldDisplayField f
    if @showAllColumns
      return true
    elsif f.displayInSimpleList
      return true
    else
      return false
    end
  end
  helper_method :shouldDisplayField
end
