class AddUnderwayToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :underway, :boolean
  end
end
