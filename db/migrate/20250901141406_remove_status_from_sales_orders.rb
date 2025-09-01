class RemoveStatusFromSalesOrders < ActiveRecord::Migration[8.0]
  def change
    remove_column :sales_orders, :status, :string
  end
end
