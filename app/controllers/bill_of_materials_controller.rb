class BillOfMaterialsController < ApplicationController
  before_action :set_product
  before_action :set_bill_of_material, only: [ :show, :edit, :update, :destroy, :activate, :copy ]

  def index
    @bill_of_materials = @product.bill_of_materials.includes(:bom_items, :materials)
                                 .order(created_at: :desc)
  end

  def show
    @bom_items = @bill_of_material.bom_items.includes(:material).order(:sequence_number, :id)
  end

  def new
    @bill_of_material = @product.bill_of_materials.build
    @materials = Material.active.order(:name)
  end

  def create
    @bill_of_material = @product.bill_of_materials.build(bill_of_material_params)

    if @bill_of_material.save
      redirect_to [ @product, @bill_of_material ], notice: "Bill of materials created successfully."
    else
      @materials = Material.active.order(:name)
      render :new
    end
  end

  def edit
    @materials = Material.active.order(:name)
  end

  def update
    if @bill_of_material.update(bill_of_material_params)
      redirect_to [ @product, @bill_of_material ], notice: "Bill of materials updated successfully."
    else
      @materials = Material.active.order(:name)
      render :edit
    end
  end

  def destroy
    @bill_of_material.destroy
    redirect_to [ @product, :bill_of_materials ], notice: "Bill of materials deleted successfully."
  end

  def activate
    @product.bill_of_materials.update_all(is_active: false)
    @bill_of_material.update!(is_active: true)
    redirect_to [ @product, @bill_of_material ], notice: "Bill of materials activated successfully."
  end

  def copy
    new_bom = @bill_of_material.dup
    new_bom.version = next_version
    new_bom.is_active = false

    if new_bom.save
      @bill_of_material.bom_items.each do |item|
        new_bom.bom_items.create!(item.attributes.except("id", "bill_of_material_id", "created_at", "updated_at"))
      end
      redirect_to [ @product, new_bom ], notice: "Bill of materials copied successfully."
    else
      redirect_to [ @product, @bill_of_material ], alert: "Failed to copy bill of materials."
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
    params.require(:bill_of_material).permit(:version, :description, :effective_date, :notes,
      bom_items_attributes: [ :id, :material_id, :quantity, :unit_of_measure, :notes,
                             :sequence_number, :is_optional, :_destroy ])
  end

  def next_version
    last_version = @product.bill_of_materials.maximum(:version) || "1.0"
    version_parts = last_version.split(".").map(&:to_i)
    version_parts[1] += 1
    version_parts.join(".")
  end
end
