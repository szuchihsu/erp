class SalesOrderItem < ApplicationRecord
  belongs_to :sales_order
  belongs_to :product

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than: 0 }

  # Add stock validation
  validate :stock_availability

  after_save :update_order_total
  after_destroy :update_order_total

  def line_total
    quantity * unit_price
  end

  def available_stock
    product.stock_quantity
  end

  def stock_sufficient?
    available_stock >= quantity
  end

  def stock_warning?
    !stock_sufficient?
  end

  private

  def stock_availability
    return unless product && quantity

    if quantity > product.stock_quantity
      errors.add(:quantity, "exceeds available stock (#{product.stock_quantity} available)")
    end
  end

  def update_order_total
    sales_order.update_total! if sales_order
  end
end
