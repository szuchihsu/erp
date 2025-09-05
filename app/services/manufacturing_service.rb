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
end
