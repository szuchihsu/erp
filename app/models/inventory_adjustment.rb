class InventoryAdjustment < ApplicationRecord
  belongs_to :item, polymorphic: true  # Changed from belongs_to :product
  belongs_to :user

  validates :quantity, presence: true, numericality: true
  validates :adjustment_type, presence: true
  validates :reason, presence: true

  scope :for_products, -> { where(item_type: "Product") }
  scope :for_materials, -> { where(item_type: "Material") }

  def display_quantity
    quantity > 0 ? "+#{quantity}" : quantity.to_s
  end

  def adjustment_description
    item_name = item.respond_to?(:name) ? item.name : "#{item.class.name} ##{item.id}"
    "#{adjustment_type.humanize}: #{display_quantity} units of #{item_name}"
  end
end
