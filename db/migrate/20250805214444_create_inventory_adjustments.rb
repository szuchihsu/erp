class CreateInventoryAdjustments < ActiveRecord::Migration[8.0]
  def change
    create_table :inventory_adjustments do |t|
      t.references :product, null: false, foreign_key: true
      t.string :adjustment_type
      t.integer :quantity
      t.string :reason
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
