class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :username, :name, :role, :employee_id ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :username, :name, :role, :employee_id ])
  end

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path  # Redirect to sign in page after sign out
  end
end
