class CreateInventoryTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :inventory_transactions do |t|
      t.references :product, null: false, foreign_key: true
      t.string :transaction_type
      t.integer :quantity
      t.string :reference_type
      t.integer :reference_id
      t.text :notes
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
