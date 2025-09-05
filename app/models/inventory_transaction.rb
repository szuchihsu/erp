class InventoryTransaction < ApplicationRecord
  belongs_to :item, polymorphic: true  # Changed from belongs_to :product
  belongs_to :user

  validates :transaction_type, presence: true, inclusion: { in: %w[in out adjustment transfer] }
  validates :quantity, presence: true, numericality: { other_than: 0 }
  validates :reference_type, presence: true

  scope :recent, -> { order(created_at: :desc).limit(50) }
  scope :for_item, ->(item) { where(item: item) }
  scope :for_products, -> { where(item_type: "Product") }
  scope :for_materials, -> { where(item_type: "Material") }
  scope :by_type, ->(type) { where(transaction_type: type) }

  def reference_object
    return nil unless reference_type && reference_id
    reference_type.constantize.find_by(id: reference_id)
  end

  # Add helper method for signed quantity
  def signed_quantity
    case transaction_type
    when "in" then quantity
    when "out" then -quantity
    when "adjustment" then quantity
    when "transfer" then quantity  # depends on context
    else 0
    end
  end

  # Update transaction description to work with any item
  def transaction_description
    item_name = item.respond_to?(:name) ? item.name : "#{item.class.name} ##{item.id}"

    case transaction_type
    when "in"
      "Stock received: #{quantity} units of #{item_name}"
    when "out"
      "Stock issued: #{quantity} units of #{item_name}"
    when "adjustment"
      "Stock adjusted: #{quantity > 0 ? '+' : ''}#{quantity} units of #{item_name}"
    when "transfer"
      "Stock transferred: #{quantity} units of #{item_name}"
    end
  end
end
