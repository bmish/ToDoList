class AddListReferenceToTasks < ActiveRecord::Migration
  def change
    add_reference :tasks, :list, index: true
  end
end
