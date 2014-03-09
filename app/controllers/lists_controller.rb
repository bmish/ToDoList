class ListsController < ApplicationController
  def update
    @list = List.find(params[:id])
    @list.update(params[:list].permit(:title))
  end
end
