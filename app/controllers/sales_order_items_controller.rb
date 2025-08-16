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

    respond_to do |format|
      if @sales_order_item.save
        # Create inventory transaction
        create_inventory_transaction("out", @sales_order_item.quantity)
        # Update sales order total
        update_sales_order_total
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
    old_quantity = @sales_order_item.quantity

    respond_to do |format|
      if @sales_order_item.update(sales_order_item_params)
        # Adjust inventory based on quantity change
        quantity_diff = @sales_order_item.quantity - old_quantity
        if quantity_diff != 0
          create_inventory_transaction("out", quantity_diff)
        end

        # Update sales order total
        update_sales_order_total
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
    # Return stock to inventory
    create_inventory_transaction("in", @sales_order_item.quantity)

    @sales_order_item.destroy
    # Update sales order total
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
      total = @sales_order.sales_order_items.sum(:total_price)
      @sales_order.update(total_amount: total)
    end

    def create_inventory_transaction(type, quantity)
      return if quantity == 0

      InventoryTransaction.create!(
        product: @sales_order_item.product,
        transaction_type: type,
        quantity: quantity.abs,
        reference_type: "SalesOrder",
        reference_id: @sales_order.id,
        notes: "Sales order #{@sales_order.order_id} - #{@sales_order_item.product.name}",
        user: current_user
      )
    end
end
