class CreateBillOfMaterials < ActiveRecord::Migration[8.0]
  def change
    create_table :bill_of_materials do |t|
      t.references :product, null: false, foreign_key: true
      t.string :version, default: "1.0"
      t.text :description
      t.boolean :is_active, default: true
      t.date :effective_date
      t.date :obsolete_date
      t.decimal :total_cost, precision: 10, scale: 2
      t.text :notes

      t.timestamps
    end

    add_index :bill_of_materials, [ :product_id, :version ], unique: true
    add_index :bill_of_materials, :is_active
  end
end
