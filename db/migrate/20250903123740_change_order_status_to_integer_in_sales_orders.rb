class ChangeOrderStatusToIntegerInSalesOrders < ActiveRecord::Migration[7.0]
  def up
    # First, convert existing string values to corresponding integers
    execute <<-SQL
      UPDATE sales_orders#{' '}
      SET order_status = CASE#{' '}
        WHEN order_status = 'inquiry' THEN '0'
        WHEN order_status = 'quotation_sent' THEN '1'
        WHEN order_status = 'pending_design' THEN '2'
        WHEN order_status = 'design_approved' THEN '3'
        WHEN order_status = 'confirmed' THEN '4'
        WHEN order_status = 'in_production' THEN '5'
        WHEN order_status = 'quality_check' THEN '6'
        WHEN order_status = 'completed' THEN '7'
        WHEN order_status = 'shipped' THEN '8'
        WHEN order_status = 'draft' THEN '0'
        WHEN order_status = 'pending' THEN '4'
        ELSE '0'
      END
      WHERE order_status IS NOT NULL;
    SQL

    # Set any NULL values to 0 (inquiry)
    execute "UPDATE sales_orders SET order_status = '0' WHERE order_status IS NULL;"

    # Change column type from string to integer
    change_column :sales_orders, :order_status, :integer, using: 'order_status::integer'

    # Set default value
    change_column_default :sales_orders, :order_status, 0
  end

  def down
    # Convert back to string if needed
    change_column :sales_orders, :order_status, :string

    execute <<-SQL
      UPDATE sales_orders#{' '}
      SET order_status = CASE#{' '}
        WHEN order_status = '0' THEN 'inquiry'
        WHEN order_status = '1' THEN 'quotation_sent'
        WHEN order_status = '2' THEN 'pending_design'
        WHEN order_status = '3' THEN 'design_approved'
        WHEN order_status = '4' THEN 'confirmed'
        WHEN order_status = '5' THEN 'in_production'
        WHEN order_status = '6' THEN 'quality_check'
        WHEN order_status = '7' THEN 'completed'
        WHEN order_status = '8' THEN 'shipped'
        ELSE 'inquiry'
      END;
    SQL
  end
end
