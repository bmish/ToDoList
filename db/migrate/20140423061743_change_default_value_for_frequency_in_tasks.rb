class ChangeDefaultValueForFrequencyInTasks < ActiveRecord::Migration
  def change
    change_column_default(:tasks, :frequency, 1)
  end
end
