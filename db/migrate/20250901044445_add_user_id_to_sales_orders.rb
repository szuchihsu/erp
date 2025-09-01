class AddUserIdToSalesOrders < ActiveRecord::Migration[8.0]
  def change
    add_reference :sales_orders, :user, null: false, foreign_key: true
  end
end
