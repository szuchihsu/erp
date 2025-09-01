class ChangeEmployeeIdToNullableInSalesOrders < ActiveRecord::Migration[7.0]
  def change
    change_column_null :sales_orders, :employee_id, true
  end
end
