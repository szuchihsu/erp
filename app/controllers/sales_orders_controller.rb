class SalesOrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_sales_order, only: %i[ show edit update destroy fulfill cancel ]

  # GET /sales_orders or /sales_orders.json
  def index
    @sales_orders = SalesOrder.includes(:customer, :sales_order_items, :products)
    @sales_orders = @sales_orders.where(order_status: params[:order_status]) if params[:order_status].present?
    @sales_orders = @sales_orders.order(created_at: :desc).limit(50)

    @status_counts = {
      total: SalesOrder.count,
      draft: SalesOrder.where(order_status: "draft").count,
      pending: SalesOrder.where(order_status: "pending").count,
      completed: SalesOrder.where(order_status: "completed").count,
      cancelled: SalesOrder.where(order_status: "cancelled").count
    }
  end

  # GET /sales_orders/1 or /sales_orders/1.json
  def show
    @sales_order_items = @sales_order.sales_order_items.includes(:product)
    @stock_warnings = @sales_order.stock_warnings
  end

  # GET /sales_orders/new
  def new
    @sales_order = SalesOrder.new
    @customers = Customer.order(:name)
    @products = Product.where("stock_quantity > 0").order(:name)
  end

  # GET /sales_orders/1/edit
  def edit
    @customers = Customer.order(:name)
    @products = Product.order(:name)
  end

  # POST /sales_orders or /sales_orders.json
  def create
    @sales_order = SalesOrder.new(sales_order_params)
    @sales_order.user = current_user
    @sales_order.order_status = "inquiry"
    @sales_order.total_amount = 0

    if @sales_order.save
      redirect_to @sales_order, notice: "Sales order was successfully created."
    else
      @customers = Customer.all
      @employees = Employee.all
      render :new
    end
  end

  # PATCH/PUT /sales_orders/1 or /sales_orders/1.json
  def update
    if @sales_order.update(sales_order_params)
      redirect_to @sales_order, notice: "Sales order was successfully updated."
    else
      @customers = Customer.order(:name)
      @products = Product.order(:name)
      render :edit, order_status: :unprocessable_entity
    end
  end

  def fulfill
    if @sales_order.fulfill_order!
      redirect_to @sales_order, notice: "Order fulfilled successfully! Inventory has been updated."
    else
      redirect_to @sales_order, alert: "Cannot fulfill order - insufficient stock for some items."
    end
  end

  def cancel
    @sales_order.update!(order_status: "cancelled", cancelled_at: Time.current)
    redirect_to @sales_order, notice: "Order cancelled."
  end

  # DELETE /sales_orders/1 or /sales_orders/1.json
  def destroy
    @sales_order.destroy
    redirect_to sales_orders_path, notice: "Sales order was successfully deleted."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sales_order
      @sales_order = SalesOrder.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def sales_order_params
      params.require(:sales_order).permit(
        :order_id,
        :customer_id,
        :employee_id,
        :order_date,
        :delivery_date,
        :quotation_amount,
        :total_amount,
        :deposit_amount,
        :remaining_amount,
        :order_status,
        :notes,
        :tax_amount,
        :shipping_amount
      )
    end
end
