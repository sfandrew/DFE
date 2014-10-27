
class DynamicFormsEngine::ApplicationController < ApplicationController
	
	layout :set_iframe_layout

	def set_iframe_layout
	    params[:iframe] == "1" ? "dynamic_forms_engine/iframe" : "application"
	end

end
