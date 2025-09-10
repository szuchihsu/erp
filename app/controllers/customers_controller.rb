class CustomersController < ApplicationController
  before_action :authorize_customer_management!, except: [ :index, :show ]
  before_action :authorize_supervisor!, only: [ :index, :show ]
  before_action :set_customer, only: %i[ show edit update destroy ]

  # GET /customers or /customers.json
  def index
    @customers = Customer.all
  end

  # GET /customers/1 or /customers/1.json
  def show
  end

  # GET /customers/new
  def new
    @customer = Customer.new
  end

  # GET /customers/1/edit
  def edit
  end

  # POST /customers or /customers.json
  def create
    @customer = Customer.new(customer_params)

    respond_to do |format|
      if @customer.save
        format.html { redirect_to @customer, notice: "Customer was successfully created." }
        format.json { render :show, status: :created, location: @customer }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /customers/1 or /customers/1.json
  def update
    respond_to do |format|
      if @customer.update(customer_params)
        format.html { redirect_to @customer, notice: "Customer was successfully updated." }
        format.json { render :show, status: :ok, location: @customer }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @customer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /customers/1 or /customers/1.json
  def destroy
    begin
      if @customer.can_be_deleted?
        @customer.destroy!
        redirect_to customers_path, notice: "Customer was successfully deleted."
      else
        counts = @customer.associated_records_count
        messages = []
        messages << "#{counts[:sales_orders]} sales orders" if counts[:sales_orders] > 0
        messages << "#{counts[:design_requests]} design requests" if counts[:design_requests] > 0

        redirect_to customer_path(@customer),
                    alert: "Cannot delete customer. Customer has #{messages.join(' and ')}. Please remove these records first."
      end
    rescue ActiveRecord::InvalidForeignKey
      redirect_to customer_path(@customer),
                  alert: "Cannot delete customer. Customer has associated records that must be removed first."
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_customer
      @customer = Customer.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def customer_params
      params.require(:customer).permit(:customer_id, :name, :email, :phone, :address, :customer_type, :status)
    end
end
