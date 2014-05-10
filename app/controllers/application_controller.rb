class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

	def configure_permitted_parameters
  	devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:email, :first_name, :last_name, :profile_name, :password, :password_confirm) }
  end

  protect_from_forgery with: :exception
end
