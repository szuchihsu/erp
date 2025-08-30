# app/controllers/inventory_controller.rb
class InventoryController < ApplicationController
  before_action :authenticate_user!

  def index
    @low_stock_products = Product.low_stock.includes(:inventory_transactions)
    @out_of_stock_products = Product.out_of_stock
    @recent_transactions = InventoryTransaction.includes(:product, :user).recent.limit(10)
    @total_inventory_value = Product.sum("stock_quantity * cost_price")
    @recent_restocks = InventoryTransaction.where(transaction_type: "in").recent.limit(5)
    @recent_adjustments = InventoryTransaction.where(transaction_type: "adjustment").recent.limit(5)
  end

  def transactions
    @transactions = InventoryTransaction.includes(:product, :user)

    # Filter by product
    if params[:product_id].present?
      @transactions = @transactions.where(product_id: params[:product_id])
      @product = Product.find(params[:product_id])
    end

    # Filter by type
    if params[:transaction_type].present?
      @transactions = @transactions.where(transaction_type: params[:transaction_type])
    end

    # Filter by date range
    if params[:start_date].present? && params[:end_date].present?
      @transactions = @transactions.where(created_at: params[:start_date]..params[:end_date])
    end

    @transactions = @transactions.order(created_at: :desc).limit(100)
  end

  def adjust_stock
    @product = Product.find(params[:product_id])
    @adjustment = InventoryAdjustment.new
  end

  def create_adjustment
    @product = Product.find(params[:product_id])
    @adjustment = @product.inventory_adjustments.build(adjustment_params)
    @adjustment.user = current_user

    if @adjustment.save
      # Create corresponding inventory transaction
      InventoryTransaction.create!(
        product: @product,
        transaction_type: "adjustment",
        quantity: @adjustment.quantity.abs,
        reference_type: "InventoryAdjustment",
        reference_id: @adjustment.id,
        notes: "#{@adjustment.adjustment_type.humanize}: #{@adjustment.reason}",
        user: current_user
      )

      # Update product stock
      new_stock = @product.stock_quantity + @adjustment.quantity
      @product.update!(stock_quantity: [ new_stock, 0 ].max) # Can't go below 0

      redirect_to inventory_path, notice: "Stock adjustment completed successfully."
    else
      render :adjust_stock, status: :unprocessable_entity
    end
  end

  def restock
    @product = Product.find(params[:product_id])
  end

  def create_restock
    @product = Product.find(params[:product_id])

    quantity = params[:quantity].to_i
    supplier = params[:supplier]
    cost = params[:cost].to_f

    if quantity > 0
      # Create inventory transaction for restock
      InventoryTransaction.create!(
        product: @product,
        transaction_type: "in",
        quantity: quantity,
        reference_type: "Restock",
        reference_id: @product.id,
        notes: build_restock_notes(supplier, cost, quantity),
        user: current_user
      )

      # Update product stock and last restocked date
      @product.update!(
        stock_quantity: @product.stock_quantity + quantity,
        last_restocked_at: Time.current
      )

      redirect_to inventory_path, notice: "Successfully restocked #{quantity} units from #{supplier}."
    else
      redirect_to restock_inventory_path(@product), alert: "Invalid quantity. Please enter a positive number."
    end
  end

  private

  def adjustment_params
    params.require(:inventory_adjustment).permit(:adjustment_type, :quantity, :reason)
  end

  def build_restock_notes(supplier, cost, quantity)
    notes = "Restocked #{quantity} units"
    notes += " from #{supplier}" if supplier.present?
    notes += " (Total cost: $#{cost})" if cost > 0
    notes
  end
end
