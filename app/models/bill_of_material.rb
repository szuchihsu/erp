class BillOfMaterial < ApplicationRecord
  belongs_to :product
  has_many :bom_items, dependent: :destroy
  has_many :materials, through: :bom_items

  accepts_nested_attributes_for :bom_items, allow_destroy: true, reject_if: proc { |attributes| attributes["material_id"].blank? }

  validates :version, presence: true, uniqueness: { scope: :product_id }
  validates :product_id, presence: true

  scope :active, -> { where(is_active: true) }
  scope :current, -> { where(is_active: true) }

  before_save :calculate_total_cost
  after_update :update_product_cost, if: :saved_change_to_total_cost?

  def display_name
    "#{product.name} - BOM v#{version}"
  end

  def material_cost
    bom_items.sum(&:total_cost)
  end

  def required_materials_available?
    bom_items.all? { |item| item.material.current_stock >= item.quantity }
  end

  def missing_materials
    bom_items.select { |item| item.material.current_stock < item.quantity }
  end

  private

  def calculate_total_cost
    cost = bom_items.sum do |item|
      item.total_cost.to_f rescue 0.0
    end
    self.total_cost = cost
  end

  def update_product_cost
    product.update(material_cost: total_cost) if product.respond_to?(:material_cost)
  end
end
