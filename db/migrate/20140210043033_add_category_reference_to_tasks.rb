class AddCategoryReferenceToTasks < ActiveRecord::Migration
  def change
    remove_column :tasks, :category, :string
    add_reference :tasks, :category, index: true
  end
end
