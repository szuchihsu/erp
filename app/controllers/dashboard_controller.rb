class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @total_employees = Employee.count
    @active_employees = Employee.where(status: "active").count
    @total_customers = Customer.count
    @active_customers = Customer.where(status: "active").count

    # Recent data
    @recent_employees = Employee.order(created_at: :desc).limit(5)
    @recent_customers = Customer.order(created_at: :desc).limit(5)

    # By department/type counts
    @employees_by_department = Employee.group(:department).count
    @customers_by_type = Customer.group(:customer_type).count
  end
end
