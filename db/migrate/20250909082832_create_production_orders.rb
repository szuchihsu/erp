class CreateProductionOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :production_orders do |t|
      t.references :sales_order, null: true, foreign_key: true  # Allow standalone production
      t.references :product, null: false, foreign_key: true
      t.references :bill_of_material, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 1
      t.integer :priority, null: false, default: 0  # 0=normal, 1=high, 2=urgent
      t.integer :status, null: false, default: 0    # enum values
      t.datetime :due_date
      t.datetime :scheduled_start
      t.datetime :scheduled_completion
      t.datetime :started_at
      t.datetime :completed_at
      t.text :notes

      t.timestamps
    end

    add_index :production_orders, :status
    add_index :production_orders, :priority
    add_index :production_orders, [ :due_date, :priority ]
  end
end
