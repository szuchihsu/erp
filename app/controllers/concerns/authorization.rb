module Authorization
  extend ActiveSupport::Concern

  class NotAuthorizedError < StandardError; end

  included do
    rescue_from Authorization::NotAuthorizedError, with: :handle_unauthorized
  end

  private

  def authorize_admin!
    raise NotAuthorizedError unless current_user&.admin?
  end

  def authorize_manager!
    raise NotAuthorizedError unless current_user&.manager?
  end

  def authorize_supervisor!
    raise NotAuthorizedError unless current_user&.supervisor?
  end

  def authorize_user_management!
    raise NotAuthorizedError unless current_user&.can_manage_users?
  end

  def authorize_employee_management!
    raise NotAuthorizedError unless current_user&.can_manage_employees?
  end

  def authorize_financial_access!
    raise NotAuthorizedError unless current_user&.can_view_financial_data?
  end

  def authorize_sales_order_creation!
    raise NotAuthorizedError unless current_user&.can_create_sales_orders?
  end

  def authorize_production_management!
    raise NotAuthorizedError unless current_user&.can_manage_production?
  end

  def authorize_work_order_access!
    raise NotAuthorizedError unless current_user&.can_work_on_orders?
  end

  def authorize_inventory_management!
    raise NotAuthorizedError unless current_user&.can_manage_inventory?
  end

  def authorize_design_management!
    raise NotAuthorizedError unless current_user&.can_manage_designs?
  end

  def authorize_quality_control!
    raise NotAuthorizedError unless current_user&.can_quality_control?
  end

  def authorize_reports_access!
    raise NotAuthorizedError unless current_user&.can_view_reports?
  end

  def authorize_customer_management!
    raise NotAuthorizedError unless current_user&.can_manage_customers?
  end

  def authorize_material_management!
    raise NotAuthorizedError unless current_user&.can_manage_materials?
  end

  def authorize_product_management!
    raise NotAuthorizedError unless current_user&.can_manage_products?
  end

  def handle_unauthorized
    flash[:alert] = "You are not authorized to access this page."
    redirect_to root_path
  end
end
