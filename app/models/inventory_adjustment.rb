class InventoryAdjustment < ApplicationRecord
  belongs_to :product
  belongs_to :user

  validates :adjustment_type, presence: true, inclusion: { in: %w[increase decrease recount damage] }
  validates :quantity, presence: true, numericality: { other_than: 0 }
  validates :reason, presence: true

  after_create :create_inventory_transaction

  def adjustment_description
    "#{adjustment_type.humanize}: #{quantity > 0 ? '+' : ''}#{quantity} units - #{reason}"
  end

  private

  def create_inventory_transaction
    InventoryTransaction.create!(
      product: product,
      transaction_type: "adjustment",
      quantity: quantity,
      reference_type: "InventoryAdjustment",
      reference_id: id,
      notes: "Manual adjustment: #{reason}",
      user: user
    )
  end
end
