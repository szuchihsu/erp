class CreateMaterials < ActiveRecord::Migration[8.0]
  def change
    create_table :materials do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.text :description
      t.string :category # gold, silver, gemstone, finding, etc.
      t.string :subcategory # 14k, 18k, emerald, clasp, etc.
      t.decimal :current_cost, precision: 10, scale: 2
      t.string :unit_of_measure, default: "gram"
      t.decimal :current_stock, precision: 10, scale: 4, default: 0
      t.decimal :minimum_stock, precision: 10, scale: 4, default: 0
      t.string :supplier
      t.boolean :is_active, default: true

      t.timestamps
    end

    add_index :materials, :code, unique: true
    add_index :materials, :category
    add_index :materials, :is_active
  end
end
