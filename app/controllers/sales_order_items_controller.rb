class SalesOrderItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_sales_order
  before_action :set_sales_order_item, only: %i[ show edit update destroy ]

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

    respond_to do |format|
      if @sales_order_item.save
        format.html { redirect_to @sales_order, notice: "Item was successfully added to the order." }
        format.json { render :show, status: :created, location: @sales_order_item }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @sales_order_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /sales_order_items/1 or /sales_order_items/1.json
  def update
    respond_to do |format|
      if @sales_order_item.update(sales_order_item_params)
        format.html { redirect_to @sales_order, notice: "Item was successfully updated." }
        format.json { render :show, status: :ok, location: @sales_order_item }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @sales_order_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /sales_order_items/1 or /sales_order_items/1.json
  def destroy
    @sales_order_item.destroy

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
end
