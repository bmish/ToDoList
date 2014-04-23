class AddStartToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :start, :date
  end
end
