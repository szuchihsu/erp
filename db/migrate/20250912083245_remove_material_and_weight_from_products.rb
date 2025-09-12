class RemoveMaterialAndWeightFromProducts < ActiveRecord::Migration[8.0]
  def change
    remove_column :products, :material, :string
    remove_column :products, :weight, :decimal
  end
end
