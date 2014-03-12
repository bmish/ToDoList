class AddIndexToTitleInTasks < ActiveRecord::Migration
  def change
    add_index :tasks, :title, unique: true
  end
end
