class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :employee, optional: true

  # Define available roles
  ROLES = %w[admin manager supervisor production_worker inventory_clerk sales_rep designer quality_control].freeze

  # Override Devise validations to remove email requirement
  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :role, inclusion: { in: ROLES }

  # Disable email validation completely
  def email_required?
    false
  end

  def email_changed?
    false
  end

  def will_save_change_to_email?
    false
  end

  # Use username for authentication
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if username = conditions.delete(:username)
      where(username: username).first
    elsif conditions.has_key?(:username)
      where(conditions.to_h).first
    end
  end

  # Role-based permission methods
  def admin?
    role == "admin"
  end

  def manager?
    role == "manager" || admin?
  end

  def supervisor?
    role == "supervisor" || manager?
  end

  def production_worker?
    role == "production_worker"
  end

  def inventory_clerk?
    role == "inventory_clerk"
  end

  def sales_rep?
    role == "sales_rep"
  end

  def designer?
    role == "designer"
  end

  def quality_control?
    role == "quality_control"
  end

  # Permission checks for major functionalities
  def can_manage_users?
    admin?
  end

  def can_manage_employees?
    manager?
  end

  def can_view_financial_data?
    admin? || manager?
  end

  def can_create_sales_orders?
    admin? || manager? || sales_rep?
  end

  def can_manage_production?
    admin? || manager? || supervisor?
  end

  def can_work_on_orders?
    admin? || manager? || supervisor? || production_worker?
  end

  def can_manage_inventory?
    admin? || manager? || inventory_clerk?
  end

  def can_manage_designs?
    admin? || manager? || designer?
  end

  def can_quality_control?
    admin? || manager? || quality_control?
  end

  def can_view_reports?
    admin? || manager? || supervisor?
  end

  def can_manage_customers?
    admin? || manager? || sales_rep?
  end

  def can_manage_materials?
    admin? || manager? || inventory_clerk?
  end

  def can_manage_products?
    admin? || manager?
  end
end
