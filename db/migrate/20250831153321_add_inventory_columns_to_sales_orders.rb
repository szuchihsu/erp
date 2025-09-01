class AddInventoryColumnsToSalesOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :sales_orders, :status, :string, default: 'draft', null: false
    add_column :sales_orders, :completed_at, :datetime
    add_column :sales_orders, :cancelled_at, :datetime
    add_column :sales_orders, :tax_amount, :decimal, precision: 10, scale: 2, default: 0.0
    add_column :sales_orders, :shipping_amount, :decimal, precision: 10, scale: 2, default: 0.0

    # Add index for better performance
    add_index :sales_orders, :status
    add_index :sales_orders, :completed_at
  end
end
