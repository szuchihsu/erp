class SalesOrderItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_sales_order
  before_action :set_sales_order_item, only: %i[ edit update destroy ]

  # GET /sales_order_items or /sales_order_items.json
  def index
    @sales_order_items = SalesOrderItem.all
  end

  # GET /sales_order_items/1 or /sales_order_items/1.json
  def show
  end

  # GET /sales_order_items/new
  def new
    @sales_order_item = @sales_order.sales_order_items.build
  end

  # GET /sales_order_items/1/edit
  def edit
  end

  # POST /sales_order_items or /sales_order_items.json
  def create
    @sales_order_item = @sales_order.sales_order_items.build(sales_order_item_params)

    # Auto-set unit price from product if not provided
    if @sales_order_item.unit_price.blank? && @sales_order_item.product
      @sales_order_item.unit_price = @sales_order_item.product.selling_price || @sales_order_item.product.cost_price
    end

    respond_to do |format|
      if @sales_order_item.save
        # DON'T create inventory transaction here - only when order is fulfilled
        update_sales_order_total
        format.html { redirect_to @sales_order, notice: "Item was successfully added to the order." }
        format.json { render :show, status: :created, location: @sales_order_item }
      else
        format.html { redirect_to @sales_order, alert: "Error adding item: #{@sales_order_item.errors.full_messages.join(', ')}" }
        format.json { render json: @sales_order_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sales_order_items/1 or /sales_order_items/1.json
  def update
    respond_to do |format|
      if @sales_order_item.update(sales_order_item_params)
        # DON'T create inventory transaction here - only when order is fulfilled
        update_sales_order_total
        format.html { redirect_to @sales_order, notice: "Item was successfully updated." }
        format.json { render :show, status: :ok, location: @sales_order_item }
      else
        format.html { redirect_to @sales_order, alert: "Error updating item: #{@sales_order_item.errors.full_messages.join(', ')}" }
        format.json { render json: @sales_order_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sales_order_items/1 or /sales_order_items/1.json
  def destroy
    # DON'T return stock here - only reduce stock when order is fulfilled
    @sales_order_item.destroy
    update_sales_order_total

    respond_to do |format|
      format.html { redirect_to @sales_order, notice: "Item was successfully removed from the order." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_sales_order
    @sales_order = SalesOrder.find(params[:sales_order_id])
  end

  def set_sales_order_item
    @sales_order_item = @sales_order.sales_order_items.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def sales_order_item_params
    params.require(:sales_order_item).permit(:product_id, :quantity, :unit_price, :specifications)
  end

  def update_sales_order_total
    # Fix this method - use line_total, not total_price
    total = @sales_order.sales_order_items.sum { |item| item.quantity * item.unit_price }
    @sales_order.update(total_amount: total)
  end

  # Remove these methods - inventory should only be updated on fulfillment
  # def create_inventory_transaction(type, quantity)
  # end
end
