class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :title
      t.string :category
      t.integer :priority
      t.text :notes
      t.boolean :done

      t.timestamps
    end
  end
end
