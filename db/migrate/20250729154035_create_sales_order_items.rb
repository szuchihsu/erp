class CreateSalesOrderItems < ActiveRecord::Migration[8.0]
  def change
    create_table :sales_order_items do |t|
      t.references :sales_order, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.integer :quantity
      t.decimal :unit_price
      t.decimal :total_price
      t.text :specifications

      t.timestamps
    end
  end
end
