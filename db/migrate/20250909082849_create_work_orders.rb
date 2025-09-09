class CreateWorkOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :work_orders do |t|
      t.references :production_order, null: false, foreign_key: true
      t.string :work_station_name, null: false
      t.string :step_name, null: false
      t.text :step_description
      t.integer :sequence, null: false, default: 1
      t.integer :status, null: false, default: 0
      t.integer :estimated_minutes, default: 60
      t.integer :actual_minutes
      t.references :assigned_employee, null: true, foreign_key: { to_table: :employees }
      t.datetime :started_at
      t.datetime :completed_at
      t.text :notes

      t.timestamps
    end

    add_index :work_orders, :status
    add_index :work_orders, :work_station_name
    add_index :work_orders, [ :production_order_id, :sequence ], unique: true
  end
end
