class AddFrequencyToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :frequency, :integer, default: 0
  end
end
