# app/controllers/inventory_controller.rb
class InventoryController < ApplicationController
  before_action :authorize_inventory_management!

  def index
    @low_stock_products = Product.low_stock.includes(:inventory_transactions)
    @out_of_stock_products = Product.out_of_stock
    @recent_transactions = InventoryTransaction.includes(:item, :user).recent.limit(10)
    @total_inventory_value = Product.sum("stock_quantity * cost_price")
    @recent_restocks = InventoryTransaction.where(transaction_type: "in").recent.limit(5)
    @recent_adjustments = InventoryTransaction.where(transaction_type: "adjustment").recent.limit(5)
  end

  def transactions
    @transactions = InventoryTransaction.includes(:item, :user)

    # Filter by item (product or material)
    if params[:product_id].present?
      @transactions = @transactions.where(item_type: "Product", item_id: params[:product_id])
      @item = Product.find(params[:product_id])
    elsif params[:material_id].present?
      @transactions = @transactions.where(item_type: "Material", item_id: params[:material_id])
      @item = Material.find(params[:material_id])
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
    @item = find_item
    return redirect_to inventory_path, alert: "Item not found" unless @item
    @adjustment = InventoryAdjustment.new
  end

  def create_adjustment
    @item = find_item
    return redirect_to inventory_path, alert: "Item not found" unless @item

    # Get form parameters
    adjustment_type = params[:adjustment_type]
    quantity = params[:quantity].to_i
    reason = params[:reason]

    # Validate input
    if quantity == 0 || reason.blank? || adjustment_type.blank?
      redirect_to adjust_inventory_path(@item), alert: "Please provide valid adjustment type, quantity, and reason."
      return
    end

    ActiveRecord::Base.transaction do
      # Create adjustment record using polymorphic relationship
      @adjustment = @item.inventory_adjustments.create!(
        adjustment_type: adjustment_type,
        quantity: quantity,
        reason: reason,
        user: current_user
      )

      # Create inventory transaction using polymorphic relationship
      InventoryTransaction.create!(
        item: @item,  # ✅ Changed from 'product:' to 'item:'
        transaction_type: "adjustment",
        quantity: quantity.abs, # Store absolute value in transaction
        reference_type: "InventoryAdjustment",
        reference_id: @adjustment.id,
        notes: "#{adjustment_type.humanize}: #{reason}",
        user: current_user
      )

      # Update item stock ONCE - manually controlled
      current_stock = @item.respond_to?(:stock_quantity) ? @item.stock_quantity : @item.current_stock
      new_stock = current_stock + quantity

      if @item.respond_to?(:stock_quantity)
        @item.update!(stock_quantity: [ new_stock, 0 ].max)
      else
        @item.update!(current_stock: [ new_stock, 0 ].max)
      end
    end

    redirect_to inventory_path, notice: "Stock adjustment completed successfully."
  rescue => e
    redirect_to adjust_inventory_path(@item), alert: "Error: #{e.message}"
  end

  def restock
    @item = find_item
    redirect_to inventory_path, alert: "Item not found" unless @item
  end

  def create_restock
    @item = find_item
    return redirect_to inventory_path, alert: "Item not found" unless @item

    quantity = params[:quantity].to_i
    supplier = params[:supplier]
    cost = params[:cost].to_f

    if quantity > 0
      ActiveRecord::Base.transaction do
        # Create transaction using polymorphic relationship
        InventoryTransaction.create!(
          item: @item,  # ✅ Changed from 'product:' to 'item:'
          transaction_type: "in",
          quantity: quantity,
          reference_type: "Restock",
          reference_id: @item.id,
          notes: build_restock_notes(supplier, cost, quantity),
          user: current_user
        )

        # Update stock ONCE - manually controlled
        current_stock = @item.respond_to?(:stock_quantity) ? @item.stock_quantity : @item.current_stock
        new_stock = current_stock + quantity

        if @item.respond_to?(:stock_quantity)
          @item.update!(
            stock_quantity: new_stock,
            last_restocked_at: Time.current
          )
        else
          @item.update!(
            current_stock: new_stock
          )
        end
      end

      item_name = @item.respond_to?(:display_name) ? @item.display_name : @item.name
      redirect_to inventory_path, notice: "Successfully restocked #{quantity} units of #{item_name}#{supplier.present? ? " from #{supplier}" : ''}."
    else
      redirect_to restock_inventory_path(@item), alert: "Invalid quantity. Please enter a positive number."
    end
  end

  private

  def find_item
    if params[:product_id].present?
      Product.find_by(id: params[:product_id])
    elsif params[:material_id].present?
      Material.find_by(id: params[:material_id])
    elsif params[:id].present?
      # Try to find by ID - first check if it's a product, then material
      Product.find_by(id: params[:id]) || Material.find_by(id: params[:id])
    else
      nil
    end
  end

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
