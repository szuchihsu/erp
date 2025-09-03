class CreateDesignRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :design_requests do |t|
      t.references :customer, null: false, foreign_key: true
      t.references :sales_order, null: true, foreign_key: true
      t.text :design_details
      t.string :status
      t.string :priority
      t.datetime :requested_date
      t.datetime :completed_date
      t.references :assigned_designer, null: true, foreign_key: { to_table: :employees }

      t.timestamps
    end
  end
end
