class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :set_current_user

  def current_user
    User.find_or_create_by(name: "Test Dummy User")
  end

  def set_current_user
  	@current_user = current_user
  end

  def authenticate_user!
    #stub
  end

end
