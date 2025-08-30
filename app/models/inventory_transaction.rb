class InventoryTransaction < ApplicationRecord
  belongs_to :product
  belongs_to :user

  validates :transaction_type, presence: true, inclusion: { in: %w[in out adjustment transfer] }
  validates :quantity, presence: true, numericality: { other_than: 0 }
  validates :reference_type, presence: true

  scope :recent, -> { order(created_at: :desc).limit(50) }
  scope :for_product, ->(product) { where(product: product) }
  scope :by_type, ->(type) { where(transaction_type: type) }

  def reference_object
    return nil unless reference_type.present? && reference_id.present?
    reference_type.classify.constantize.find_by(id: reference_id)
  end

  def transaction_description
    case transaction_type
    when "in"
      "Stock received: #{quantity} units"
    when "out"
      "Stock sold: #{quantity} units"
    when "adjustment"
      "Stock adjusted: #{quantity > 0 ? '+' : ''}#{quantity} units"
    when "transfer"
      "Stock transferred: #{quantity} units"
    end
  end

  def signed_quantity
    case transaction_type
    when "out"
      -quantity.abs
    when "in", "adjustment"
      quantity
    else
      quantity
    end
  end
end
