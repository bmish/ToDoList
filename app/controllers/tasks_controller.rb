class TasksController < ApplicationController
  def new
    redirect_to tasks_path
  end
  
  def create
    @task = Task.new(task_params)
    if @task.save
      @task = nil;
      index()
      render :index
    else
      index()
      render :index
    end
  end
  
  def show
    @task = Task.find(params[:id])
  end
  
  def index
    if !verifyCurrentList()
      head(:internal_server_error)
      return
    end

    # Get the current list.
    @lists = List.all
    @list = List.find(getCurrentListID())
    
    # Determine how to sort the tasks.
    sort = getSortFromParams()
    @constrainedSort = (sort != Sort::NONE)
    if sort == Sort::NONE
      sort = Sort::PRIORITY # Default sort.
    end
    sqlSort = getSQLForSort(sort)

    tasksQuery = Task.joins('LEFT JOIN categories ON tasks.category_id = categories.id').order(sqlSort).where(list_id: @list.id).where(deleted: false).select("tasks.*, categories.title as category_title")

    @showPriorityHeaders = (sort == Sort::PRIORITY) && !(params[:priorityHeaders] == 'false')
    @showCategoryHeaders = (sort == Sort::PRIORITY) && !(params[:categoryHeaders] == 'false')

    @constrainedPriority = false
    if params[:priority] && params[:priority].to_i >= 0 && params[:priority].to_i <= 3
      @constrainedPriority = true
      tasksQuery = tasksQuery.where(priority: params[:priority].to_i)
    end

    @constrainedCategory = false
    if params[:category] && params[:category].to_i >= 1
      @constrainedCategory = true
      tasksQuery = tasksQuery.where(category_id: params[:category].to_i)
      @showCategoryHeaders = false # It's unnecessary to show category headers when we are constrained to one category.
    end
    
    @constrainedCreated = false
    if params[:created] && !params[:created].empty?
      @constrainedCreated = true
      created = Time.strptime(params[:created], "%F")
      tasksQuery = tasksQuery.where(created_at: (created.midnight..(created.midnight + 1.day - 1.second)))
    end

    @constrainedStart = false
    if params[:start] && !params[:start].empty?
      @constrainedStart = true
      tasksQuery = tasksQuery.where(start: params[:start])
    end
    
    @constrainedDue = false
    if params[:due] && !params[:due].empty?
      @constrainedDue = true
      tasksQuery = tasksQuery.where(due: params[:due])
    end

    @constrainedLocation = false
    if params[:location] && !params[:location].empty?
      @constrainedLocation = true
      tasksQuery = tasksQuery.where(location: params[:location])
    end

    @constrainedFrequency = false
    if params[:frequency] && !params[:frequency].empty?
      @constrainedFrequency = true
      tasksQuery = tasksQuery.where(frequency: Task.frequencies[params[:frequency]])
    end

    @constrainedDependee = false
    if params[:dependee] && !params[:dependee].empty?
      @constrainedDependee = true
      tasksQuery = tasksQuery.where(dependee: params[:dependee])
    end

    @tasks = tasksQuery
    
    @constrainedList = (@constrainedSort || @constrainedPriority || @constrainedCategory || @constrainedCreated || @constrainedStart || @constrainedDue || @constrainedLocation || @constrainedFrequency || @constrainedDependee)
  end
  
  def edit
    @task = Task.find(params[:id])
  end
  
  def update
    @task = Task.find(params[:id])
    
    if @task.update(params[:task].permit(:title, :category_id, :priority, :notes, :list_id))
      redirect_to @task
    else
      edit()
      render 'edit'
    end
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
      logger.error "Bad file_data: #{file_data.class.name}: #{file_data.inspect}"
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
    end
    
    redirect_to tasks_path, flash: {importCountSucceeded: @importCountSucceeded, importCountFailed: @importCountFailed}
  end
  
  private
  def task_params
    params.require(:task).permit(:title, :category_id, :priority, :notes, :list_id, :blocked, :start, :due, :location, :frequency, :dependee)
  end
  
  def importCSVRow row
    task = Task.new
    if row['Task']; task.title = row['Task'] end
    if row['Priority']; task.priority = row['Priority'] end
    if row['Notes']; task.notes = row['Notes'] end
    if row['Done']; task.done = row['Done'] end
    #if row['Created at']; task.created_at = row['Created at'] end
    #if row['Updated at']; task.updated_at = row['Updated at'] end
    if row['Category']; task.category_id = Category.find_or_create_by(title: row['Category']).id end
    task.list_id = getCurrentListID()
    if row['Deleted']; task.deleted = row['Deleted'] end
    if row['Blocked']; task.blocked = row['Blocked'] end
    #if row['Due']; task.due = row['Due'] end
    if row['Location']; task.location = row['Location'] end
    if row['Frequency']; task.frequency = row['Frequency'] end
    if row['Dependee']; task.dependee = row['Dependee'] end
    #if row['Start']; task.start = row['Start'] end

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

  def getSortFromParams
    sort = nil
    if params[:sort] == 'priority'
      sort = Sort::PRIORITY
    elsif params[:sort] == 'category'
      sort = Sort::CATEGORY
    elsif params[:sort] == 'task'
      sort = Sort::TASK
    elsif params[:sort] == 'created'
      sort = Sort::CREATED
    elsif params[:sort] == 'start'
      sort = Sort::START
    elsif params[:sort] == 'due'
      sort = Sort::DUE
    elsif params[:sort] == 'blocked'
      sort = Sort::BLOCKED
    elsif params[:sort] == 'location'
      sort = Sort::LOCATION
    elsif params[:sort] == 'frequency'
      sort = Sort::FREQUENCY
    elsif params[:sort] == 'dependee'
      sort = Sort::DEPENDEE
    else
      sort = Sort::NONE
    end
    return sort
  end

  def getSQLForSort sort
    sql = ''
    if sort == Sort::PRIORITY
      sql = 'tasks.priority, LOWER(categories.title), LOWER(tasks.title)'
    elsif sort == Sort::CATEGORY
      sql = 'LOWER(categories.title), tasks.priority, LOWER(tasks.title)'
    elsif sort == Sort::TASK
      sql = 'LOWER(tasks.title), tasks.priority, LOWER(categories.title)'
    elsif sort == Sort::CREATED
      sql = 'tasks.created_at DESC, tasks.priority, LOWER(categories.title), LOWER(tasks.title)'
    elsif sort == Sort::START
      sql = 'tasks.start DESC, tasks.priority, LOWER(categories.title), LOWER(tasks.title)'
    elsif sort == Sort::DUE
      sql = 'tasks.due DESC, tasks.priority, LOWER(categories.title), LOWER(tasks.title)'
    elsif sort == Sort::BLOCKED
      sql = 'tasks.blocked DESC, tasks.priority, LOWER(categories.title), LOWER(tasks.title)'
    elsif sort == Sort::LOCATION
      sql = 'LOWER(tasks.location), tasks.priority, LOWER(categories.title), LOWER(tasks.title)'
    elsif sort == Sort::FREQUENCY
      sql = 'tasks.frequency, tasks.priority, LOWER(categories.title), LOWER(tasks.title)'
    elsif sort == Sort::DEPENDEE
      sql = 'tasks.dependee, tasks.priority, LOWER(categories.title), LOWER(tasks.title)'
    end
    return sql
  end

  module Sort
    NONE = 0
    PRIORITY = 1
    CATEGORY = 2
    TASK = 3
    CREATED = 4
    START = 5
    DUE = 6
    BLOCKED = 7
    LOCATION = 8
    FREQUENCY = 9
    DEPENDEE = 10
  end

  def getCurrentListID
    return cookies['list_id'] ? cookies['list_id'] : 1;
  end

  def verifyCurrentList
    if List.count == 0
      return false
    else
      begin
        list = List.find(getCurrentListID())
      rescue ActiveRecord::RecordNotFound
        list = List.first # Default to the first list.
        cookies['list_id'] = list.id
      end
    end

    return true
  end
end
