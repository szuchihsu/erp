class Employee < ApplicationRecord
  # Fix the supervisor association to point to Employee model
  belongs_to :supervisor, class_name: "Employee", optional: true
  has_many :subordinates, class_name: "Employee", foreign_key: "supervisor_id"

  has_one :user

  validates :employee_id, presence: true, uniqueness: true
  validates :name, presence: true
  validates :department, inclusion: { in: [ "production", "quality", "sales", "admin" ] }, allow_blank: true
  validates :status, inclusion: { in: [ "active", "inactive", "terminated" ] }, allow_blank: true

  scope :active, -> { where(status: "active") }
  scope :by_department, ->(dept) { where(department: dept) }
end
