class CreateSalesOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :sales_orders do |t|
      t.string :order_id
      t.references :customer, null: false, foreign_key: true
      t.references :employee, null: false, foreign_key: true
      t.datetime :order_date
      t.datetime :delivery_date
      t.decimal :quotation_amount
      t.decimal :total_amount
      t.decimal :deposit_amount
      t.decimal :remaining_amount
      t.string :order_status
      t.text :notes

      t.timestamps
    end
  end
end
