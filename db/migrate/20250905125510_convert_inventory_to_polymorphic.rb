class ConvertInventoryToPolymorphic < ActiveRecord::Migration[8.0]
  def up
    # Step 1.1: Add polymorphic columns to inventory_transactions
    add_column :inventory_transactions, :item_type, :string
    add_column :inventory_transactions, :item_id, :bigint

    # Step 1.2: Add polymorphic columns to inventory_adjustments
    add_column :inventory_adjustments, :item_type, :string
    add_column :inventory_adjustments, :item_id, :bigint

    # Step 1.3: Migrate existing inventory_transactions data
    InventoryTransaction.reset_column_information
    InventoryTransaction.find_each do |transaction|
      transaction.update_columns(
        item_type: 'Product',
        item_id: transaction.product_id
      )
    end

    # Step 1.4: Migrate existing inventory_adjustments data
    InventoryAdjustment.reset_column_information
    InventoryAdjustment.find_each do |adjustment|
      adjustment.update_columns(
        item_type: 'Product',
        item_id: adjustment.product_id
      )
    end

    # Step 1.5: Add indexes for performance
    add_index :inventory_transactions, [ :item_type, :item_id ]
    add_index :inventory_adjustments, [ :item_type, :item_id ]

    # Step 1.6: Remove old product_id columns
    remove_column :inventory_transactions, :product_id
    remove_column :inventory_adjustments, :product_id
  end

  def down
    # Rollback steps (reverse order)
    add_column :inventory_transactions, :product_id, :bigint
    add_column :inventory_adjustments, :product_id, :bigint

    # Migrate data back
    InventoryTransaction.reset_column_information
    InventoryTransaction.where(item_type: 'Product').find_each do |transaction|
      transaction.update_columns(product_id: transaction.item_id)
    end

    InventoryAdjustment.reset_column_information
    InventoryAdjustment.where(item_type: 'Product').find_each do |adjustment|
      adjustment.update_columns(product_id: adjustment.item_id)
    end

    remove_index :inventory_transactions, [ :item_type, :item_id ]
    remove_index :inventory_adjustments, [ :item_type, :item_id ]
    remove_column :inventory_transactions, :item_type
    remove_column :inventory_transactions, :item_id
    remove_column :inventory_adjustments, :item_type
    remove_column :inventory_adjustments, :item_id
  end
end
