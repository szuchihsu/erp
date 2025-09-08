class BillOfMaterialsController < ApplicationController
  before_action :set_product
  before_action :set_bill_of_material, only: [ :show, :edit, :update, :destroy, :activate, :copy ]

  def index
    @bill_of_materials = @product.bill_of_materials.includes(bom_items: :material).order(:version)
    @active_bom = @bill_of_materials.active.first
  end

  def show
    @bom_items = @bill_of_material.bom_items.includes(:material).order(:sequence_number)
  end

  def new
    @bill_of_material = @product.bill_of_materials.build
    @bill_of_material.version = generate_next_version
    @bill_of_material.bom_items.build # Start with one empty BOM item
  end

  def create
    @bill_of_material = @product.bill_of_materials.build(bill_of_material_params)
    @bill_of_material.version = generate_next_version

    respond_to do |format|
      if @bill_of_material.save
        format.html { redirect_to [ @product, @bill_of_material ], notice: "Bill of Material was successfully created." }
        format.json { render :show, status: :created, location: [ @product, @bill_of_material ] }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @bill_of_material.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @bill_of_material.update(bill_of_material_params)
        format.html { redirect_to [ @product, @bill_of_material ], notice: "Bill of Material was successfully updated." }
        format.json { render :show, status: :ok, location: [ @product, @bill_of_material ] }
      else
        # ✅ Add debugging information
        Rails.logger.error "BOM Update Error: #{@bill_of_material.errors.full_messages}"
        @bill_of_material.bom_items.each_with_index do |item, index|
          Rails.logger.error "BOM Item #{index}: #{item.errors.full_messages}" if item.errors.any?
        end

        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @bill_of_material.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @bill_of_material.destroy!

    respond_to do |format|
      format.html { redirect_to product_bill_of_materials_path(@product), notice: "Bill of Material was successfully deleted." }
      format.json { head :no_content }
    end
  end

  def activate
    @bill_of_material.activate!
    redirect_to product_bill_of_materials_path(@product), notice: "Bill of Material activated successfully."
  end

  def copy
    new_bom = @bill_of_material.copy_to_new_version
    if new_bom.persisted?
      redirect_to edit_product_bill_of_material_path(@product, new_bom),
                  notice: "BOM copied to version #{new_bom.version}. You can now modify it."
    else
      redirect_to product_bill_of_materials_path(@product),
                  alert: "Failed to copy BOM."
    end
  end

  private

  def set_product
    @product = Product.find(params[:product_id])
  end

  def set_bill_of_material
    @bill_of_material = @product.bill_of_materials.find(params[:id])
  end

  def bill_of_material_params
    params.require(:bill_of_material).permit(
      :description, :notes, :is_active,
      bom_items_attributes: [
        :id, :material_id, :quantity, :unit_of_measure,
        :sequence_number, :notes, :is_optional, :_destroy
      ]
    )
  end

  def generate_next_version
    existing_count = @product.bill_of_materials.count
    "#{existing_count + 1}.0"
  end
end
