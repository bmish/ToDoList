class TasksController < ApplicationController
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
    @LIST_ID = 1 # Temporarily hard-coded.
    @list = List.find(@LIST_ID)
    
    # Determine how to sort the tasks.
    if !params[:sort] || params[:sort].empty? || params[:sort] == 'priority'
      @sort = 'tasks.done, tasks.priority, LOWER(categories.title), LOWER(tasks.title)'
    elsif params[:sort] == 'category'
      @sort = 'tasks.done, LOWER(categories.title), tasks.priority, LOWER(tasks.title)'
    elsif params[:sort] == 'task'
      @sort = 'tasks.done, LOWER(tasks.title), tasks.priority, LOWER(categories.title)'
    end
    
    tasksQuery = Task.joins(:category).order(@sort).where(list_id: @list.id).where(deleted: false)
    
    if params[:priority] && params[:priority].to_i >= 0 && params[:priority].to_i <= 3
      tasksQuery = tasksQuery.where(priority: params[:priority].to_i)
    end
      
    if params[:category] && params[:category].to_i >= 1
      tasksQuery = tasksQuery.where(category_id: params[:category].to_i)
    end
    
    @tasks = tasksQuery
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
  
  private
  def task_params
    params.require(:task).permit(:title, :category_id, :priority, :notes, :list_id)
  end
end
