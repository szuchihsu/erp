class Customer < ApplicationRecord
  validates :customer_id, presence: true, uniqueness: true
  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :customer_type, inclusion: { in: ["retail", "wholesale", "vip"] }, allow_blank: true
  validates :status, inclusion: { in: ["active", "inactive", "blocked"] }, allow_blank: true

  scope :active, -> { where(status: "active") }
  scope :by_type, ->(type) { where(customer_type: type) }

  def display_name
    "#{customer_id} - #{name}"
  end
end
