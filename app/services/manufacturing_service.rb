# app/services/manufacturing_service.rb
class ManufacturingService
  def self.consume_materials(bill_of_material, quantity = 1)
    ActiveRecord::Base.transaction do
      bill_of_material.bom_items.each do |bom_item|
        material = bom_item.material
        required_quantity = bom_item.quantity * quantity

        if material.current_stock < required_quantity
          raise "Insufficient stock for #{material.name}. Required: #{required_quantity}, Available: #{material.current_stock}"
        end

        # Create inventory transaction using polymorphic relationship
        InventoryTransaction.create!(
          item: material,  # Polymorphic - points to Material
          user: Current.user,  # Assuming you have current user
          transaction_type: "out",
          quantity: required_quantity,
          reference_type: "BillOfMaterial",
          reference_id: bill_of_material.id,
          notes: "Material consumed for #{bill_of_material.product.name} production"
        )

        # Update material stock
        material.update!(current_stock: material.current_stock - required_quantity)
      end
    end
  end

  def self.fulfill_order_with_materials(sales_order)
    new(sales_order).fulfill_order_with_materials
  end

  def self.fulfill_order_from_stock(sales_order)
    new(sales_order).fulfill_order_from_stock
  end

  def initialize(sales_order)
    @sales_order = sales_order
  end

  def fulfill_order_with_materials
    return false unless @sales_order.can_be_fulfilled?
    return false unless materials_available_for_order?

    ActiveRecord::Base.transaction do
      @sales_order.sales_order_items.each do |item|
        # 1. Reduce product inventory
        reduce_product_inventory(item)

        # 2. Consume materials based on BOM
        consume_materials_for_product(item)

        # 3. Create product inventory transaction
        create_product_transaction(item)
      end

      @sales_order.update!(order_status: "completed", completed_at: Time.current)
    end
    true
  rescue => e
    Rails.logger.error "Manufacturing fulfillment failed: #{e.message}"
    false
  end

  def materials_available_for_order?
    @sales_order.sales_order_items.all? do |item|
      product = item.product
      active_bom = product.bill_of_materials.active.first

      next true unless active_bom # No BOM means no material check needed

      active_bom.bom_items.where(is_optional: false).all? do |bom_item|
        material_needed = bom_item.quantity * item.quantity
        bom_item.material.current_stock >= material_needed
      end
    end
  end

  def get_material_shortages
    shortages = []
    @sales_order.sales_order_items.each do |item|
      product = item.product
      active_bom = product.bill_of_materials.active.first

      next unless active_bom

      active_bom.bom_items.where(is_optional: false).each do |bom_item|
        material_needed = bom_item.quantity * item.quantity
        if bom_item.material.current_stock < material_needed
          shortages << {
            product: product.name,
            material: bom_item.material.name,
            needed: material_needed,
            available: bom_item.material.current_stock,
            shortage: material_needed - bom_item.material.current_stock
          }
        end
      end
    end
    shortages
  end

  # New method for fulfilling orders from finished stock only
  def fulfill_order_from_stock
    return false unless @sales_order.can_be_fulfilled?

    ActiveRecord::Base.transaction do
      @sales_order.sales_order_items.each do |item|
        # Only reduce product inventory (no material consumption)
        reduce_product_inventory(item)
        create_product_transaction(item)
      end

      @sales_order.update!(order_status: "completed", completed_at: Time.current)
    end
    true
  rescue => e
    Rails.logger.error "Stock fulfillment failed: #{e.message}"
    false
  end

  private

  def reduce_product_inventory(sales_order_item)
    product = sales_order_item.product
    new_stock = product.stock_quantity - sales_order_item.quantity
    product.update!(stock_quantity: [ new_stock, 0 ].max)
  end

  def consume_materials_for_product(sales_order_item)
    product = sales_order_item.product
    active_bom = product.bill_of_materials.active.first

    return unless active_bom

    active_bom.bom_items.where(is_optional: false).each do |bom_item|
      # Calculate total material needed (BOM quantity × product quantity)
      material_needed = bom_item.quantity * sales_order_item.quantity

      # Reduce material inventory
      reduce_material_inventory(bom_item.material, material_needed, sales_order_item)
    end
  end

  def reduce_material_inventory(material, quantity_needed, sales_order_item)
    # Reduce material stock
    new_stock = material.current_stock - quantity_needed
    material.update!(current_stock: [ new_stock, 0 ].max)

    # Create material inventory transaction
    InventoryTransaction.create!(
      item: material,
      transaction_type: "out",
      quantity: quantity_needed, # Positive quantity, transaction_type indicates direction
      reference_type: "SalesOrder",
      reference_id: @sales_order.id,
      notes: "Material consumed for #{sales_order_item.product.name} - Order ##{@sales_order.id}",
      user: @sales_order.user
    )
  end

  def create_product_transaction(sales_order_item)
    InventoryTransaction.create!(
      item: sales_order_item.product,
      transaction_type: "out",
      quantity: sales_order_item.quantity, # Positive quantity, transaction_type indicates direction
      reference_type: "SalesOrder",
      reference_id: @sales_order.id,
      notes: "Sold to #{@sales_order.customer.name} - Order ##{@sales_order.id}",
      user: @sales_order.user
    )
  end
end
