class UpdateProductsForInventoryManagement < ActiveRecord::Migration[7.0]
  def change
    # Rename minimum_stock to minimum_stock_level for consistency
    rename_column :products, :minimum_stock, :minimum_stock_level

    # Add new inventory fields
    add_column :products, :reserved_stock, :decimal, default: 0.0
    add_column :products, :last_restocked_at, :datetime
    add_column :products, :reorder_point, :decimal
    add_column :products, :optimal_stock_level, :decimal

    # Add indexes for better performance
    add_index :products, :stock_quantity
    add_index :products, :minimum_stock_level
    add_index :products, [ :stock_quantity, :minimum_stock_level ], name: 'index_products_on_stock_levels'
  end
end
