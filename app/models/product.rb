class Product < ApplicationRecord
  has_many :sales_order_items, dependent: :destroy
  has_many :sales_orders, through: :sales_order_items
  has_many :inventory_transactions, dependent: :destroy
  has_many :inventory_adjustments, dependent: :destroy

  validates :product_id, presence: true, uniqueness: true
  validates :name, presence: true
  validates :category, inclusion: { in: [ "rings", "necklaces", "bracelets", "earrings", "watches", "pendants" ] }, allow_blank: true
  validates :status, inclusion: { in: [ "active", "discontinued", "out_of_stock" ] }, allow_blank: true
  validates :cost_price, numericality: { greater_than: 0 }, allow_nil: true
  validates :selling_price, numericality: { greater_than: 0 }, allow_nil: true
  validates :stock_quantity, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :minimum_stock_level, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :active, -> { where(status: "active") }
  scope :low_stock, -> { where("stock_quantity <= minimum_stock_level AND minimum_stock_level IS NOT NULL") }
  scope :out_of_stock, -> { where(stock_quantity: 0) }
  scope :by_category, ->(category) { where(category: category) }

  def display_name
    "#{product_id} - #{name}"
  end

  def profit_margin
    return 0 unless cost_price && selling_price && cost_price > 0
    ((selling_price - cost_price) / cost_price * 100).round(2)
  end

  def low_stock?
    return false unless stock_quantity && minimum_stock_level
    stock_quantity <= minimum_stock_level
  end

  # New inventory management methods
  def available_stock
    stock_quantity - (reserved_stock || 0)
  end

  def stock_status
    return "out_of_stock" if stock_quantity == 0
    return "low_stock" if low_stock?
    "in_stock"
  end

  def stock_status_badge_class
    case stock_status
    when "out_of_stock"
      "bg-red-100 text-red-800"
    when "low_stock"
      "bg-yellow-100 text-yellow-800"
    when "in_stock"
      "bg-green-100 text-green-800"
    end
  end

  def stock_value
    return 0 unless stock_quantity && cost_price
    stock_quantity * cost_price
  end

  def inventory_value
    return 0 unless stock_quantity && selling_price
    stock_quantity * selling_price
  end

  def days_of_stock_remaining
    return Float::INFINITY unless minimum_stock_level && stock_quantity > 0

    # Calculate average daily usage based on recent sales
    recent_sales = sales_order_items.joins(:sales_order)
                                   .where(sales_orders: { created_at: 30.days.ago..Time.current })
                                   .sum(:quantity)

    return Float::INFINITY if recent_sales == 0

    daily_usage = recent_sales / 30.0
    (stock_quantity / daily_usage).round(1)
  end

  def reorder_needed?
    return false unless minimum_stock_level
    stock_quantity <= minimum_stock_level
  end

  def can_fulfill_order?(quantity)
    available_stock >= quantity
  end

  def reserve_stock(quantity)
    return false unless can_fulfill_order?(quantity)

    self.reserved_stock = (reserved_stock || 0) + quantity
    save
  end

  def release_stock(quantity)
    return false unless reserved_stock && reserved_stock >= quantity

    self.reserved_stock -= quantity
    save
  end

  def last_transaction
    inventory_transactions.order(created_at: :desc).first
  end

  def stock_movement_history(limit = 10)
    inventory_transactions.includes(:user).order(created_at: :desc).limit(limit)
  end

  # Class methods for inventory reporting
  def self.total_inventory_value
    sum("stock_quantity * cost_price")
  end

  def self.total_retail_value
    sum("stock_quantity * selling_price")
  end

  def self.low_stock_count
    low_stock.count
  end

  def self.out_of_stock_count
    out_of_stock.count
  end

  # Update stock quantity (use this instead of direct assignment)
  def adjust_stock(quantity, reason: nil, user: nil)
    old_quantity = stock_quantity
    new_quantity = old_quantity + quantity

    return false if new_quantity < 0

    transaction do
      update!(stock_quantity: new_quantity)

      # Create inventory transaction record
      if user
        inventory_transactions.create!(
          transaction_type: quantity > 0 ? "in" : "out",
          quantity: quantity.abs,
          reference_type: "Adjustment",
          reference_id: id,
          notes: reason || "Manual stock adjustment",
          user: user
        )
      end
    end

    true
  rescue
    false
  end

  private

  # Ensure minimum_stock is renamed to minimum_stock_level in migration
  def minimum_stock
    minimum_stock_level
  end
end
