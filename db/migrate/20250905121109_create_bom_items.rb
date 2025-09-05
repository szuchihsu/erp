class CreateBomItems < ActiveRecord::Migration[8.0]
  def change
    create_table :bom_items do |t|
      t.references :bill_of_material, null: false, foreign_key: true
      t.references :material, null: false, foreign_key: true
      t.decimal :quantity, precision: 10, scale: 4, null: false
      t.string :unit_of_measure, default: "gram"
      t.decimal :unit_cost, precision: 10, scale: 2
      t.decimal :total_cost, precision: 10, scale: 2
      t.text :notes
      t.integer :sequence_number
      t.boolean :is_optional, default: false

      t.timestamps
    end
  end
end
