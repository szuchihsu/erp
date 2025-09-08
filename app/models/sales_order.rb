class SalesOrder < ApplicationRecord
  belongs_to :customer
  belongs_to :user
  belongs_to :employee, optional: true
  has_many :sales_order_items, dependent: :destroy
  has_many :products, through: :sales_order_items
  has_one :design_request, dependent: :destroy

  # Update validation to match new enum values
  validates :order_status, presence: true, inclusion: {
    in: %w[inquiry quotation_sent pending_design design_approved confirmed in_production quality_check completed shipped]
  }

  # Fix enum syntax for Rails 8
  enum :order_status, {
    inquiry: 0,
    quotation_sent: 1,
    pending_design: 2,    # When custom design is needed
    design_approved: 3,   # Design completed and approved
    confirmed: 4,         # Customer confirmed order
    in_production: 5,     # Manufacturing started
    quality_check: 6,     # In quality control
    completed: 7,         # Ready for shipment
    shipped: 8           # Delivered to customer
  }

  enum :fulfillment_type, {
    from_stock: 0,        # Ship finished goods directly from inventory
    make_to_order: 1      # Manufacture using materials when order is fulfilled
  }

  def subtotal
    sales_order_items.sum { |item| item.quantity * item.unit_price }
  end

  def update_total!
    self.total_amount = subtotal + (tax_amount || 0) + (shipping_amount || 0)
    save!
  end

  def can_be_fulfilled?
    # Always check product stock first
    return false unless sales_order_items.all? { |item| item.stock_sufficient? }

    # For make-to-order, also check material availability
    if make_to_order?
      manufacturing_service = ManufacturingService.new(self)
      manufacturing_service.materials_available_for_order?
    else
      true # from_stock only needs product availability
    end
  end

  def fulfill_order!
    if make_to_order?
      # Use manufacturing service for make-to-order (consumes materials)
      ManufacturingService.fulfill_order_with_materials(self)
    else
      # Simple stock fulfillment (only reduces product inventory)
      ManufacturingService.fulfill_order_from_stock(self)
    end
  end

  def material_shortages
    # Only check material shortages for make-to-order
    return [] unless make_to_order?

    manufacturing_service = ManufacturingService.new(self)
    manufacturing_service.get_material_shortages
  end

  def stock_warnings
    warnings = []

    # Product stock warnings
    sales_order_items.each do |item|
      if item.product.stock_quantity < item.quantity
        warnings << "#{item.product.name}: Need #{item.quantity}, have #{item.product.stock_quantity}"
      end
    end

    # Material shortage warnings
    material_shortages.each do |shortage|
      warnings << "#{shortage[:product]} - Material #{shortage[:material]}: Need #{shortage[:needed]}, have #{shortage[:available]} (shortage: #{shortage[:shortage]})"
    end

    warnings
  end

  def requires_custom_design?
    design_request.present?
  end

  def can_start_production?
    confirmed? && (!requires_custom_design? || design_approved?)
  end

  def design_status
    return "no_design_needed" unless requires_custom_design?
    design_request.status
  end

  def display_name
    "Order ##{id} - #{customer.name} (#{order_status.humanize})"
  end
end
