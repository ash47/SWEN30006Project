class ApplicationController < ActionController::Base
	before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :check_notifications, if: :user_signed_in?

  protected

	def configure_permitted_parameters
  	devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:email, :first_name, :last_name, :profile_name, :password, :password_confirm) }
  end

  def check_notifications
    if user_signed_in?
      @notifications = current_user.messages.where(:read => false).count

      if current_user.admin
        @admin_notifications = Club.find(:all, :conditions => {:confirmed => false}).count
      end
    end
  end

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
end
