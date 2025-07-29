class SalesOrder < ApplicationRecord
  belongs_to :customer
  belongs_to :employee
  has_many :sales_order_items, dependent: :destroy
  has_many :products, through: :sales_order_items

  validates :order_id, presence: true, uniqueness: true
  validates :order_date, presence: true
  validates :order_status, inclusion: { in: [ "pending", "confirmed", "in_production", "completed", "cancelled" ] }

  scope :by_status, ->(status) { where(order_status: status) }
  scope :recent, -> { order(order_date: :desc) }

  def display_name
    "#{order_id} - #{customer.name}"
  end

  def calculate_total
    sales_order_items.sum(:total_price)
  end
end
