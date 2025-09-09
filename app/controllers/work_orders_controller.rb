class WorkOrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_production_order
  before_action :set_work_order, only: [ :show, :edit, :update, :start_work, :complete_work ]

  def show
  end

  def edit
  end

  def update
    if @work_order.update(work_order_params)
      redirect_to @production_order, notice: "Work order was successfully updated."
    else
      render :edit
    end
  end

  def start_work
    employee = Employee.find(params[:employee_id]) if params[:employee_id].present?

    if @work_order.start_work!(employee || current_user.employee || Employee.first)
      redirect_to @production_order, notice: "Started work on #{@work_order.step_name}."
    else
      redirect_to @production_order, alert: "Could not start work on #{@work_order.step_name}."
    end
  end

  def complete_work
    actual_minutes = params[:work_order][:actual_minutes].to_i

    if actual_minutes > 0 && @work_order.complete_work!(actual_minutes)
      redirect_to @production_order, notice: "Completed #{@work_order.step_name} in #{actual_minutes} minutes."
    else
      redirect_to @production_order, alert: "Could not complete work. Please enter valid time."
    end
  end

  private

  def set_production_order
    @production_order = ProductionOrder.find(params[:production_order_id])
  end

  def set_work_order
    @work_order = @production_order.work_orders.find(params[:id])
  end

  def work_order_params
    params.require(:work_order).permit(:assigned_employee_id, :notes, :actual_minutes)
  end
end
