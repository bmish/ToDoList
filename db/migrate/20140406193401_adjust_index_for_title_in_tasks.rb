class AdjustIndexForTitleInTasks < ActiveRecord::Migration
  def change
    remove_index :tasks, name: 'index_tasks_on_title'
    add_index :tasks, [:title, :list_id], unique: true
  end
end
