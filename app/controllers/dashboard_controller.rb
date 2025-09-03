class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @total_employees = Employee.count
    @active_employees = Employee.where(status: "active").count
    @total_customers = Customer.count
    @active_customers = Customer.where(status: "active").count
    @total_products = Product.count
    @low_stock_products = Product.low_stock.count

    # Recent data
    @recent_employees = Employee.order(created_at: :desc).limit(5)
    @recent_customers = Customer.order(created_at: :desc).limit(5)
    @recent_products = Product.order(created_at: :desc).limit(5)
    @recent_design_requests = DesignRequest.includes(:customer).order(created_at: :desc).limit(5)

    # Grouped data with safe defaults
    @employees_by_department = Employee.group(:department).count || {}
    @customers_by_type = Customer.group(:customer_type).count || {}
    @products_by_category = Product.group(:category).count || {}

    # Design metrics
    @design_metrics = {
      pending_designs: DesignRequest.where(status: :pending).count,
      designs_in_progress: DesignRequest.where(status: [ :assigned, :in_progress ]).count,
      designs_for_review: DesignRequest.where(status: :review).count,
      overdue_designs: DesignRequest.where("requested_date < ? AND status IN (?)", 7.days.ago, [ "pending", "assigned", "in_progress" ]).count
    }
  end
end
