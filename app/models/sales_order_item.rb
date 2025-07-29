class SalesOrderItem < ApplicationRecord
  belongs_to :sales_order
  belongs_to :product

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :unit_price, presence: true, numericality: { greater_than: 0 }

  before_save :calculate_total_price

  private

  def calculate_total_price
    self.total_price = quantity * unit_price
  end
end
