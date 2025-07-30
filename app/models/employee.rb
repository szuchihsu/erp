class Employee < ApplicationRecord
  # Fix the supervisor association to point to Employee model
  belongs_to :supervisor, class_name: "Employee", optional: true
  has_many :subordinates, class_name: "Employee", foreign_key: "supervisor_id"

  has_one :user
  has_many :sales_orders, dependent: :destroy

  validates :employee_id, presence: true, uniqueness: true
  validates :name, presence: true
  # validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :department, inclusion: { in: [ "production", "sales", "admin", "quality_control", "management" ] }, allow_blank: true
  validates :status, inclusion: { in: [ "active", "inactive", "terminated" ] }, allow_blank: true

  scope :active, -> { where(status: "active") }
  scope :by_department, ->(dept) { where(department: dept) }

  def display_name
    "#{employee_id} - #{name}"
  end
end
