class ListsController < ApplicationController
  def create
    list = List.create(title: 'New list')
    success = true

    response = {}
    response["list"] = list

    respond_to do |format|
      if success
        format.json { render :json => response }
      else
        format.json { head(:internal_server_error) }
      end
    end
  end

  def update
    @list = List.find(params[:id])
    @list.update(params[:list].permit(:title))
    success = true

    respond_to do |format|
        format.json { head (success ? :ok : :internal_server_error)}
    end
  end

  def show
    cookies['list_id'] = params[:id]
    redirect_to tasks_path
  end
end
