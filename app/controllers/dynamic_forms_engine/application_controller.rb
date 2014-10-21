
class DynamicFormsEngine::ApplicationController < ApplicationController
	layout :set_iframe_layout

	def set_iframe_layout
	    Rails.logger.warn "\n\nPARAMS: #{params} IFRAME? #{params[:iframe]=="1"}\n\n\n"
	    params[:iframe] == "1" ? "dynamic_forms_engine/iframe" : "application"
	end
end
