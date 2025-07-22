class CreateEmployees < ActiveRecord::Migration[7.0]
  def change
    create_table :employees do |t|
      t.string :employee_id
      t.string :name
      t.string :email
      t.string :phone
      t.string :department
      t.string :position
      t.date :hire_date
      t.decimal :salary
      t.string :status
      t.integer :supervisor_id  # Change this line

      t.timestamps
    end

    add_index :employees, :employee_id, unique: true
    add_foreign_key :employees, :employees, column: :supervisor_id  # Add this line
  end
end
