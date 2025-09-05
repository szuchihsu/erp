class Material < ApplicationRecord
  has_many :inventory_transactions, as: :item, dependent: :restrict_with_error
  has_many :inventory_adjustments, as: :item, dependent: :restrict_with_error
  has_many :bom_items, dependent: :restrict_with_error
  has_many :bill_of_materials, through: :bom_items

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
  validates :current_cost, numericality: { greater_than_or_equal_to: 0 }
  validates :current_stock, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(is_active: true) }
  scope :by_category, ->(category) { where(category: category) }
  scope :low_stock, -> { where("current_stock <= minimum_stock") }

  enum :category, {
    precious_metal: 0,
    gemstone: 1,
    finding: 2,
    tool: 3,
    consumable: 4,
    packaging: 5
  }

  def display_name
    "#{code} - #{name}"
  end

  def stock_status
    return "out_of_stock" if current_stock <= 0
    return "low_stock" if current_stock <= minimum_stock
    "in_stock"
  end

  def stock_value
    current_stock * current_cost
  end

  # Method to calculate stock from transactions (if needed)
  def calculated_stock
    inventory_transactions.sum(&:signed_quantity)
  end
end
