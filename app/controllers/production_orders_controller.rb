class ProductionOrdersController < ApplicationController
  before_action :set_production_order, only: [ :show, :edit, :update, :destroy, :start, :complete ]

  def index
    @production_orders = ProductionOrder.includes(:product, :sales_order, :work_orders)

    # Filter by status if specified
    @production_orders = @production_orders.where(status: params[:status]) if params[:status].present?

    # Filter by priority if specified
    @production_orders = @production_orders.where(priority: params[:priority]) if params[:priority].present?

    # Sort by priority and due date
    @production_orders = @production_orders.by_priority

    # Pagination could be added here if needed
    @production_orders = @production_orders.limit(50)
  end

  def show
    @work_orders = @production_order.work_orders.by_sequence.includes(:assigned_employee)
  end

  def new
    @production_order = ProductionOrder.new
    @sales_order = SalesOrder.find(params[:sales_order_id]) if params[:sales_order_id]
    @products = Product.joins(:bill_of_materials).where(bill_of_materials: { is_active: true }).distinct
  end

  def create
    @production_order = ProductionOrder.new(production_order_params)

    # Set BOM automatically if not specified
    if @production_order.bill_of_material.nil? && @production_order.product.present?
      @production_order.bill_of_material = @production_order.product.bill_of_materials.active.first
    end

    if @production_order.save
      @production_order.generate_work_orders!
      redirect_to @production_order, notice: "Production order was successfully created."
    else
      @products = Product.joins(:bill_of_materials).where(bill_of_materials: { is_active: true }).distinct
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @products = Product.joins(:bill_of_materials).where(bill_of_materials: { is_active: true }).distinct
  end

  def update
    if @production_order.update(production_order_params)
      redirect_to @production_order, notice: "Production order was successfully updated."
    else
      @products = Product.joins(:bill_of_materials).where(bill_of_materials: { is_active: true }).distinct
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @production_order.pending? || @production_order.material_allocated?
      @production_order.destroy
      redirect_to production_orders_path, notice: "Production order was successfully deleted."
    else
      redirect_to @production_order, alert: "Cannot delete production order that is in progress or completed."
    end
  end

  def start
    if @production_order.start_production!
      redirect_to @production_order, notice: "Production started successfully!"
    else
      redirect_to @production_order, alert: "Could not start production. Check order status."
    end
  end

  def complete
    if @production_order.complete_production!
      redirect_to @production_order, notice: "Production completed successfully!"
    else
      redirect_to @production_order, alert: "Could not complete production. Check order status."
    end
  end

  private

  def set_production_order
    @production_order = ProductionOrder.find(params[:id])
  end

  def production_order_params
    params.require(:production_order).permit(
      :sales_order_id, :product_id, :bill_of_material_id, :quantity,
      :priority, :due_date, :notes
    )
  end
end
