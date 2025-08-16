# app/controllers/inventory_controller.rb
class InventoryController < ApplicationController
  before_action :authenticate_user!

  def index
    @low_stock_products = Product.low_stock.includes(:inventory_transactions)
    @out_of_stock_products = Product.out_of_stock
    @recent_transactions = InventoryTransaction.includes(:product, :user).recent
    @total_inventory_value = Product.sum("stock_quantity * cost_price")
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

    @transactions = @transactions.order(created_at: :desc).page(params[:page])
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
      redirect_to inventory_index_path, notice: "Stock adjustment completed successfully."
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
      # Create inventory transaction
      InventoryTransaction.create!(
        product: @product,
        transaction_type: "in",
        quantity: quantity,
        reference_type: "Restock",
        reference_id: @product.id,
        notes: "Restocked from #{supplier}. Cost: $#{cost}",
        user: current_user
      )

      # Update last restocked date
      @product.update(last_restocked_at: Time.current)

      redirect_to inventory_index_path, notice: "Successfully restocked #{quantity} units."
    else
      redirect_to inventory_index_path, alert: "Invalid quantity."
    end
  end

  private

  def adjustment_params
    params.require(:inventory_adjustment).permit(:adjustment_type, :quantity, :reason)
  end
end
