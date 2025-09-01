class SalesOrder < ApplicationRecord
  belongs_to :customer
  belongs_to :user
  belongs_to :employee, optional: true
  has_many :sales_order_items, dependent: :destroy
  has_many :products, through: :sales_order_items

  validates :order_status, presence: true, inclusion: { in: %w[draft pending confirmed shipped completed cancelled] }

  # Add these methods for inventory integration
  def subtotal
    sales_order_items.sum { |item| item.quantity * item.unit_price }
  end

  def update_total!
    self.total_amount = subtotal + (tax_amount || 0) + (shipping_amount || 0)
    save!
  end

  def can_be_fulfilled?
    sales_order_items.all? { |item| item.stock_sufficient? }
  end

  def fulfill_order!
    return false unless can_be_fulfilled?

    ActiveRecord::Base.transaction do
      sales_order_items.each do |item|
        # Reduce inventory
        new_stock = item.product.stock_quantity - item.quantity
        item.product.update!(stock_quantity: [ new_stock, 0 ].max)

        # Create inventory transaction
        InventoryTransaction.create!(
          product: item.product,
          transaction_type: "out",
          quantity: item.quantity,
          reference_type: "SalesOrder",
          reference_id: self.id,
          notes: "Sold to #{customer.name} - Order ##{id}",
          user: user
        )
      end

      update!(order_status: "completed", completed_at: Time.current)
    end
    true
  end

  def stock_warnings
    warnings = []
    sales_order_items.each do |item|
      if item.product.stock_quantity < item.quantity
        warnings << "#{item.product.name}: Need #{item.quantity}, have #{item.product.stock_quantity}"
      end
    end
    warnings
  end
end
