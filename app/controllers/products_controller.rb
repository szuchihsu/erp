class ProductsController < ApplicationController
  before_action :authorize_product_management!, except: [ :index, :show ]
  before_action :authorize_supervisor!, only: [ :index, :show ]
  before_action :set_product, only: %i[ show edit update destroy ]

  # GET /products or /products.json
  def index
    @products = Product.all

    # Search functionality
    if params[:search].present?
      @products = @products.where("name ILIKE ? OR product_id ILIKE ? OR description ILIKE ?",
                                 "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%")
    end

    # Filter by category
    if params[:category].present?
      @products = @products.where(category: params[:category])
    end

    # Filter by status
    if params[:status].present?
      @products = @products.where(status: params[:status])
    end

    @products = @products.order(:name)
  end

  # GET /products/1 or /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products or /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: "Product was successfully created." }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1 or /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: "Product was successfully updated." }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1 or /products/1.json
  def destroy
    @product.destroy!

    respond_to do |format|
      format.html { redirect_to products_path, status: :see_other, notice: "Product was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def product_params
      params.require(:product).permit(
        :product_id, :name, :description, :category, :dimensions,
        :cost_price, :selling_price, :stock_quantity, :minimum_stock_level,
        :reserved_stock, :last_restocked_at, :reorder_point, :optimal_stock_level,
        :supplier_info, :status
      )
    end
end
