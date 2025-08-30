class InventoryAdjustment < ApplicationRecord
  belongs_to :product
  belongs_to :user

  validates :quantity, presence: true, numericality: true
  validates :adjustment_type, presence: true
  validates :reason, presence: true

  # Remove the automatic transaction creation
  # after_create :create_inventory_transaction

  # Add helper methods instead
  def display_quantity
    quantity > 0 ? "+#{quantity}" : quantity.to_s
  end

  def adjustment_description
    "#{adjustment_type.humanize}: #{reason}"
  end

  # Remove the private create_inventory_transaction method
end
