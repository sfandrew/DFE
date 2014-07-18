module DynamicFormsEngine
  class ApplicationController < ActionController::Base
  	def current_user
  	  User.find_or_create_by(name: "Test Dummy User")
  	end
  end
end
