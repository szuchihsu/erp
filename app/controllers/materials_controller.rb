class MaterialsController < ApplicationController
  before_action :set_material, only: [ :show, :edit, :update, :destroy ]

  def index
    @materials = Material.includes(:inventory_transactions)
    @materials = @materials.where(category: params[:category]) if params[:category].present?
    @materials = @materials.where("name ILIKE ?", "%#{params[:search]}%") if params[:search].present?
    @materials = @materials.order(:name)
  end

  def show
    @recent_transactions = InventoryTransaction.for_item(@material).recent.limit(10)
    @recent_adjustments = InventoryAdjustment.where(item: @material).order(created_at: :desc).limit(5)
  end

  def new
    @material = Material.new
  end

  def create
    @material = Material.new(material_params)

    respond_to do |format|
      if @material.save
        format.html { redirect_to @material, notice: "Material was successfully created." }
        format.json { render :show, status: :created, location: @material }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @material.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @material.update(material_params)
        format.html { redirect_to @material, notice: "Material was successfully updated." }
        format.json { render :show, status: :ok, location: @material }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @material.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @material.bom_items.any?
        format.html { redirect_to @material, alert: "Cannot delete material that is used in bill of materials." }
        format.json { render json: { error: "Material is used in bill of materials" }, status: :unprocessable_entity }
      else
        @material.destroy!
        format.html { redirect_to materials_path, notice: "Material was successfully deleted." }
        format.json { head :no_content }
      end
    end
  end

  private

  def set_material
    @material = Material.find(params[:id])
  end

  def material_params
    params.require(:material).permit(:name, :code, :description, :category, :subcategory,
                                     :current_cost, :unit_of_measure, :current_stock,
                                     :minimum_stock, :supplier, :is_active)
  end
end
