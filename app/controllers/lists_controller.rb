class ListsController < ApplicationController
  def update
    @list = List.find(params[:id])
    @list.update(params[:list].permit(:title))
    success = true

    respond_to do |format|
        format.json { head (success ? :ok : :internal_server_error)}
    end
  end
end
