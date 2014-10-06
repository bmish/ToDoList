class CreateFields < ActiveRecord::Migration
  def change
    create_table :fields do |t|
      t.string :name, null: false
      t.string :titleForDB
      t.string :titleForList
      t.string :titleForCSV
      t.string :titleForForm
      t.string :dataType
      t.integer :orderDisplay
      t.integer :orderSort
      t.boolean :displayInSimpleList, null: false, default: false
      t.boolean :displayInFullList, null: false, default: false
      t.boolean :isFormField, null: false, default: false

      t.timestamps
    end

    add_index :fields, :name, :unique => true
    add_index :fields, :orderDisplay, :unique => true
    add_index :fields, :orderSort, :unique => true
  end
end
