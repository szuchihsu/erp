class CreateCustomers < ActiveRecord::Migration[8.0]
  def change
    create_table :customers do |t|
      t.string :customer_id
      t.string :name
      t.string :email
      t.string :phone
      t.text :address
      t.string :customer_type
      t.string :status

      t.timestamps
    end
  end
end
