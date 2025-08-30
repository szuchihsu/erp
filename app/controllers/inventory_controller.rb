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

    # Get form parameters
    adjustment_type = params[:adjustment_type]
    quantity = params[:quantity].to_i
    reason = params[:reason]

    # Validate input
    if quantity == 0 || reason.blank? || adjustment_type.blank?
      redirect_to adjust_inventory_path(@product), alert: "Please provide valid adjustment type, quantity, and reason."
      return
    end

    ActiveRecord::Base.transaction do
      # Create adjustment record (no automatic transaction creation)
      @adjustment = @product.inventory_adjustments.create!(
        adjustment_type: adjustment_type,
        quantity: quantity,
        reason: reason,
        user: current_user
      )

      # Create inventory transaction (no automatic stock update)
      InventoryTransaction.create!(
        product: @product,
        transaction_type: "adjustment",
        quantity: quantity.abs, # Store absolute value in transaction
        reference_type: "InventoryAdjustment",
        reference_id: @adjustment.id,
        notes: "#{adjustment_type.humanize}: #{reason}",
        user: current_user
      )

      # Update product stock ONCE - manually controlled
      new_stock = @product.stock_quantity + quantity
      @product.update!(stock_quantity: [ new_stock, 0 ].max)
    end

    redirect_to inventory_path, notice: "Stock adjustment completed successfully."
  rescue => e
    redirect_to adjust_inventory_path(@product), alert: "Error: #{e.message}"
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
      ActiveRecord::Base.transaction do
        # Create transaction (no automatic stock update)
        InventoryTransaction.create!(
          product: @product,
          transaction_type: "in",
          quantity: quantity,
          reference_type: "Restock",
          reference_id: @product.id,
          notes: build_restock_notes(supplier, cost, quantity),
          user: current_user
        )

        # Update stock ONCE - manually controlled
        @product.update!(
          stock_quantity: @product.stock_quantity + quantity,
          last_restocked_at: Time.current
        )
      end

      redirect_to inventory_path, notice: "Successfully restocked #{quantity} units#{supplier.present? ? " from #{supplier}" : ''}."
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
