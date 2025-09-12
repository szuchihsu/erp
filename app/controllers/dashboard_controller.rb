class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @total_employees = Employee.count
    @active_employees = Employee.where(status: "active").count
    @total_customers = Customer.count
    @active_customers = Customer.where(status: "active").count
    @total_products = Product.count
    @low_stock_products = Product.low_stock.count

    # Additional stats
    @total_sales_orders = SalesOrder.count
    @pending_sales_orders = SalesOrder.where(order_status: :inquiry).count
    @total_production_orders = ProductionOrder.count
    @active_production_orders = ProductionOrder.where(status: [ :pending, :in_production ]).count
    @total_design_requests = DesignRequest.count
    @pending_design_requests = DesignRequest.where(status: :pending).count
    @total_materials = Material.count
    @low_stock_materials = Material.where("current_stock <= minimum_stock").count

    # Recent data
    @recent_employees = Employee.order(created_at: :desc).limit(5)
    @recent_customers = Customer.order(created_at: :desc).limit(5)
    @recent_products = Product.order(created_at: :desc).limit(5)
    @recent_design_requests = DesignRequest.includes(:customer).order(created_at: :desc).limit(5)
    @recent_sales_orders = SalesOrder.includes(:customer).order(created_at: :desc).limit(5)
    @recent_production_orders = ProductionOrder.includes(:product).order(created_at: :desc).limit(5)

    # Grouped data with safe defaults
    @employees_by_department = Employee.group(:department).count || {}
    @customers_by_type = Customer.group(:customer_type).count || {}
    @products_by_category = Product.group(:category).count || {}
    @sales_orders_by_status = SalesOrder.group(:order_status).count || {}
    @production_orders_by_status = ProductionOrder.group(:status).count || {}

    # Design metrics
    @design_metrics = {
      pending_designs: DesignRequest.where(status: :pending).count,
      designs_in_progress: DesignRequest.where(status: [ :assigned, :in_progress ]).count,
      designs_for_review: DesignRequest.where(status: :review).count,
      overdue_designs: DesignRequest.where("requested_date < ? AND status IN (?)", 7.days.ago, [ "pending", "assigned", "in_progress" ]).count
    }
  end
end
