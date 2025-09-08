class AddFulfillmentTypeToSalesOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :sales_orders, :fulfillment_type, :integer, default: 0, null: false
    add_index :sales_orders, :fulfillment_type
  end
end
