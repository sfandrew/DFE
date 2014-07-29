require_dependency "dynamic_forms_engine/application_controller"

module DynamicFormsEngine
  class Api::DynamicFormEntriesController < ApplicationController

  	def get_many
  		if params[:form_type_id]
  			render json: DynamicFormType.find(params[:form_type_id].to_i).entries.to_json
  		end
  	else
  		render json: []
  	end

  end
end
