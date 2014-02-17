class TasksController < ApplicationController
  def new
    @task = Task.new
  end
  
  def create
    @task = Task.new(task_params)
    if @task.save
      @task = nil;
      @tasks = Task.all
      render 'index'
    else
      @tasks = Task.all
      render 'index'
    end
  end
  
  def show
    @task = Task.find(params[:id])
  end
  
  def index
    @tasks = Task.all
  end
  
  def edit
    @task = Task.find(params[:id])
  end
  
  def update
    @task = Task.find(params[:id])
    
    if @task.update(params[:task].permit(:title, :category_id, :priority, :notes))
      redirect_to @task
    else
      render 'edit'
    end
  end
  
  def destroy
    @task = Task.find(params[:id])
    @task.destroy
    
    redirect_to tasks_path
  end
  
  private
  def task_params
    params.require(:task).permit(:title, :category_id, :priority, :notes)
  end
end
