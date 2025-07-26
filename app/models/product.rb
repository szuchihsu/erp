class Product < ApplicationRecord
  validates :product_id, presence: true, uniqueness: true
  validates :name, presence: true
  validates :category, inclusion: { in: [ "rings", "necklaces", "bracelets", "earrings", "watches", "pendants" ] }, allow_blank: true
  validates :status, inclusion: { in: [ "active", "discontinued", "out_of_stock" ] }, allow_blank: true
  validates :cost_price, numericality: { greater_than: 0 }, allow_nil: true
  validates :selling_price, numericality: { greater_than: 0 }, allow_nil: true
  validates :stock_quantity, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :minimum_stock, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :active, -> { where(status: "active") }
  scope :low_stock, -> { where("stock_quantity <= minimum_stock") }
  scope :by_category, ->(category) { where(category: category) }

  def display_name
    "#{product_id} - #{name}"
  end

  def profit_margin
    return 0 unless cost_price && selling_price && cost_price > 0
    ((selling_price - cost_price) / cost_price * 100).round(2)
  end

  def low_stock?
    return false unless stock_quantity && minimum_stock
    stock_quantity <= minimum_stock
  end
end
