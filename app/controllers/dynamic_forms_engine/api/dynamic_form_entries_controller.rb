require_dependency "dynamic_forms_engine/application_controller"

module DynamicFormsEngine
  class Api::DynamicFormEntriesController < ApplicationController

  	def get_many
  		if params[:form_type_id]
  			render json: format_json_response(DynamicFormType.find(params[:form_type_id].to_i).entries.includes(:dynamic_form_type))
  		else
  			render json: format_json_response(nil)
  		end
  	end


  	private

  	def format_json_response(data, meta=nil)
  		{data: data, meta: (meta || {code: 200})}.to_json
  	end

  end
end
