
class DynamicFormsEngine::ApplicationController < ApplicationController
	
	layout :set_iframe_layout

	def set_iframe_layout
	    Rails.logger.warn "\n\nPARAMS: #{params} IFRAME? #{params[:iframe]=="1"}\n\n\n"
	    # params[:iframe] == "1" ? "dynamic_forms_engine/iframe" : "application"
	    if params[:iframe] == "1"
	    	"dynamic_forms_engine/iframe"
	    elsif params[:format] == "print"
	    	"dynamic_forms_engine/dynamic_form_entries.print"
	    else
	    	"application"
	    end	
	end

	# def authenticate_user!
	    
	#     # stub
	    
	# end

end
