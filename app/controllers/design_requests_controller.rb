class DesignRequestsController < ApplicationController
  before_action :authorize_design_management!, except: [ :index, :show ]
  before_action :authorize_supervisor!, only: [ :index, :show ]
  before_action :set_design_request, only: [ :show, :edit, :update, :approve, :reject, :assign, :destroy ]

  def index
    @design_requests = DesignRequest.includes(:customer, :sales_order, :assigned_designer)

    # Filter by status if provided
    if params[:status].present?
      @design_requests = @design_requests.where(status: params[:status])
    end

    # Filter by priority if provided
    if params[:priority].present?
      @design_requests = @design_requests.where(priority: params[:priority])
    end

    # Filter by designer if provided
    if params[:designer_id].present?
      @design_requests = @design_requests.where(assigned_designer_id: params[:designer_id])
    end

    @design_requests = @design_requests.order(created_at: :desc).page(params[:page])

    # Metrics for dashboard
    @metrics = {
      pending: DesignRequest.pending.count,
      in_progress: DesignRequest.in_progress.count,
      review: DesignRequest.review.count,
      overdue: DesignRequest.overdue.count
    }

    @designers = Employee.designers.active
  end

  def show
    # Fix: Use with_attached_image_file instead of includes_attached
    @design_images = @design_request.design_images.with_attached_image_file.order(:created_at)
    @final_images = @design_images.where(is_final: true)
    @work_images = @design_images.where(is_final: false)
  end

  def new
    @design_request = DesignRequest.new
    @customers = Customer.active.order(:name)
    @sales_orders = SalesOrder.where(order_status: [ "inquiry", "quotation_sent" ]).includes(:customer)
    @designers = Employee.designers.active.order(:name)
  end

  def create
    @design_request = DesignRequest.new(design_request_params)
    @design_request.requested_date = Time.current
    @design_request.status = params[:draft] ? :pending : :pending
    @design_request.priority ||= :medium

    if @design_request.save
      # Update sales order status if applicable
      if @design_request.sales_order
        @design_request.sales_order.update!(order_status: "pending_design")
      end

      redirect_to @design_request, notice: "Design request created successfully. You can now upload images."
    else
      @customers = Customer.active.order(:name)
      @sales_orders = SalesOrder.where(order_status: [ "inquiry", "quotation_sent" ]).includes(:customer)
      @designers = Employee.designers.active.order(:name)
      render :new
    end
  end

  def edit
    @designers = Employee.designers.active
  end

  def update
    if @design_request.update(design_request_params)
      redirect_to @design_request, notice: "Design request updated successfully."
    else
      @designers = Employee.designers.active
      render :edit
    end
  end

  def approve
    if @design_request.can_be_approved?
      @design_request.update!(
        status: "approved",
        completed_date: Time.current
      )

      # Update related sales order status
      if @design_request.sales_order
        @design_request.sales_order.update!(order_status: "design_approved")
      end

      redirect_to @design_request, notice: "Design approved successfully!"
    else
      redirect_to @design_request, alert: "Cannot approve design without final images."
    end
  end

  def reject
    @design_request.update!(
      status: "rejected",
      completed_date: Time.current
    )

    redirect_to @design_request, notice: "Design request rejected."
  end

  def assign
    designer = Employee.find(params[:designer_id])

    @design_request.update!(
      assigned_designer: designer,
      status: "assigned"
    )

    redirect_to @design_request, notice: "Design request assigned to #{designer.name}."
  end

  def destroy
    @design_request.destroy
    redirect_to design_requests_path, notice: "Design request was successfully deleted."
  end

  private

  def set_design_request
    @design_request = DesignRequest.find(params[:id])
  end

  # This method is now only used by the show view through DesignImagesController
  def handle_image_uploads
    return unless params[:design_images]

    params[:design_images].each do |image_params|
      next unless image_params[:image_file].present?

      design_image = @design_request.design_images.build(
        image_file: image_params[:image_file],
        image_type: image_params[:image_type],
        description: image_params[:description],
        is_final: false
      )

      unless design_image.save
        Rails.logger.warn "Failed to save design image: #{design_image.errors.full_messages}"
      end
    end
  end

  def design_request_params
    params.require(:design_request).permit(
      :customer_id, :sales_order_id, :design_details, :priority,
      :assigned_designer_id, :status
    )
  end
end
