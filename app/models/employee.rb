class Employee < ApplicationRecord
  # Fix the supervisor association to point to Employee model
  belongs_to :supervisor, class_name: "Employee", optional: true
  has_many :subordinates, class_name: "Employee", foreign_key: "supervisor_id"

  has_one :user
  has_many :sales_orders, dependent: :destroy
  has_many :assigned_design_requests, class_name: "DesignRequest", foreign_key: "assigned_designer_id"
  has_many :work_orders, foreign_key: "assigned_employee_id", dependent: :nullify

  validates :employee_id, presence: true, uniqueness: true
  validates :name, presence: true
  # validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :department, inclusion: {
    in: [ "production", "quality", "sales", "admin", "design" ]
  }, allow_blank: true
  validates :status, inclusion: { in: [ "active", "inactive", "terminated" ] }, allow_blank: true

  scope :active, -> { where(status: "active") }
  scope :by_department, ->(dept) { where(department: dept) }
  scope :designers, -> { where(department: "design") }
  scope :available_designers, -> { designers.where(status: "active") }

  def display_name
    "#{employee_id} - #{name}"
  end

  def is_designer?
    department == "design"
  end

  def active_design_requests
    assigned_design_requests.active
  end

  def design_workload
    assigned_design_requests.where(status: [ "assigned", "in_progress", "review" ]).count
  end
end
