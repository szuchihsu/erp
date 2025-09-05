class BomItem < ApplicationRecord
  belongs_to :bill_of_material
  belongs_to :material

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_of_measure, presence: true

  before_save :calculate_total_cost
  after_save :update_bom_total
  after_destroy :update_bom_total

  scope :required, -> { where(is_optional: false) }
  scope :optional, -> { where(is_optional: true) }

  def cost_per_unit
    unit_cost || material.current_cost || 0
  end

  def total_material_cost
    quantity * cost_per_unit
  end

  private

  def calculate_total_cost
    self.unit_cost = cost_per_unit
    self.total_cost = total_material_cost
  end

  def update_bom_total
    bill_of_material.update_columns(
      total_cost: bill_of_material.bom_items.sum(:total_cost),
      updated_at: Time.current
    )
  end
end
