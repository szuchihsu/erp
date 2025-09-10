class UsersController < ApplicationController
  before_action :authorize_admin!
  before_action :set_user, only: [ :show, :edit, :update, :destroy ]

  def index
    @users = User.includes(:employee).order(:username)
    @users = @users.where(role: params[:role]) if params[:role].present?
  end

  def show
  end

  def new
    @user = User.new
    @employees = Employee.where.not(id: User.where.not(employee_id: nil).pluck(:employee_id))
  end

  def create
    @user = User.new(user_params)
    @user.password = params[:user][:password] || SecureRandom.hex(8)

    if @user.save
      redirect_to users_path, notice: "User was successfully created."
    else
      @employees = Employee.where.not(id: User.where.not(employee_id: nil).pluck(:employee_id))
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @employees = Employee.where.not(id: User.where.not(employee_id: nil).pluck(:employee_id))
    @employees = Employee.where(id: [ @user.employee_id ] + @employees.pluck(:id)).compact if @user.employee_id
  end

  def update
    user_update_params = user_params
    user_update_params.delete(:password) if user_update_params[:password].blank?

    if @user.update(user_update_params)
      redirect_to users_path, notice: "User was successfully updated."
    else
      @employees = Employee.where.not(id: User.where.not(employee_id: nil).pluck(:employee_id))
      @employees = Employee.where(id: [ @user.employee_id ] + @employees.pluck(:id)).compact if @user.employee_id
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user == current_user
      redirect_to users_path, alert: "You cannot delete your own account."
    else
      @user.destroy
      redirect_to users_path, notice: "User was successfully deleted."
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:username, :name, :role, :employee_id, :password, :password_confirmation)
  end
end
