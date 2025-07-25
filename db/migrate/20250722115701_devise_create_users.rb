# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      ## Database authenticatable
      t.string :username,           null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      t.string :name
      t.string :role
      t.references :employee, foreign_key: true, null: true

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      t.timestamps null: false
    end

    add_index :users, :username,             unique: true
    add_index :users, :reset_password_token, unique: true
    # Remove email index since we're not using email
  end
end
