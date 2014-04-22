class AddDependeeToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :dependee, :string
  end
end
