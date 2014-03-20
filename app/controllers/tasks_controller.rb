class TasksController < ApplicationController
  LIST_ID = 1 # TODO: Temporarily hard-coded.
  
  def new
    @task = Task.new
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
    # Get the current list.
    @list = List.find(LIST_ID)
    
    # Determine how to sort the tasks.
    if !params[:sort] || params[:sort].empty? || params[:sort] == 'priority'
      sort = 'tasks.done, tasks.priority, LOWER(categories.title), LOWER(tasks.title)'
    elsif params[:sort] == 'category'
      sort = 'tasks.done, LOWER(categories.title), tasks.priority, LOWER(tasks.title)'
    elsif params[:sort] == 'task'
      sort = 'tasks.done, LOWER(tasks.title), tasks.priority, LOWER(categories.title)'
    end
    
    tasksQuery = Task.joins(:category).order(sort).where(list_id: @list.id).where(deleted: false).select("tasks.*, categories.title as category_title")
    
    if params[:priority] && params[:priority].to_i >= 0 && params[:priority].to_i <= 3
      tasksQuery = tasksQuery.where(priority: params[:priority].to_i)
    end
      
    if params[:category] && params[:category].to_i >= 1
      tasksQuery = tasksQuery.where(category_id: params[:category].to_i)
    end
    
    @tasks = tasksQuery
    
    @listConstrained = (params[:sort] || params[:priority] || params[:category])
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
    @task.save
    
    redirect_to tasks_path
  end
  
  def complete
    @task = Task.find(params[:id])
    @task.done = params[:completed] ? true : false
    @task.save
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
    params.require(:task).permit(:title, :category_id, :priority, :notes, :list_id)
  end
  
  def importCSVRow row
    task = Task.new
    task.title = row['Task']
    task.priority = row['Priority']
    task.category_id = Category.find_or_create_by(title: row['Category']).id
    task.list_id = LIST_ID

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
end
