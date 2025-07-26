class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :product_id
      t.string :name
      t.text :description
      t.string :category
      t.string :material
      t.decimal :weight
      t.decimal :cost_price
      t.decimal :selling_price
      t.integer :stock_quantity
      t.integer :minimum_stock
      t.string :supplier
      t.string :status

      t.timestamps
    end
  end
end
