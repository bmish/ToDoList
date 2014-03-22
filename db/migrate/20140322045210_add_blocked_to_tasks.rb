class AddBlockedToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :blocked, :boolean, default: false
  end
end
