class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.integer :kind, null: false
      t.date :arrival_date, null: false
      t.text :note

      t.timestamps
    end
  end
end
