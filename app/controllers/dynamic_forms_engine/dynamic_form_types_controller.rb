require_dependency "dynamic_forms_engine/application_controller"

module DynamicFormsEngine
  class DynamicFormTypesController < ApplicationController
    
    before_filter :authenticate_user!

    before_action :set_dynamic_form_type, only: [:show, :edit, :update, :destroy]
    before_filter :non_editable_dynamic_forms, only: [:show, :edit, :update, :destroy]


    # GET /dynamic_form_types
    # GET /dynamic_form_types.json
    def index
      @dynamic_form_types = DynamicFormType.where(:user_id => current_user.id)
    end

    # GET /dynamic_form_types/1
    # GET /dynamic_form_types/1.json
    def show
      @form_fields = @dynamic_form_type.ordered_fields
    end

    # GET /dynamic_form_types/new
    def new
      @dynamic_form_type = DynamicFormType.new
    end
    # GET /dynamic_form_types/1/edit
    def edit
    end

    # POST /dynamic_form_types
    # POST /dynamic_form_types.json
    def create
      create_dynamic_form_type(dynamic_form_type_params)
    end

    #Used for create AND save as
    def create_dynamic_form_type(params)
      @dynamic_form_type = DynamicFormType.new(params)
      @dynamic_form_type.user_id = current_user.id 
      respond_to do |format|
        if @dynamic_form_type.save
          format.html { redirect_to @dynamic_form_type, notice: 'Dynamic form type was successfully saved.' }
          format.json { render action: 'show', status: :created, location: @dynamic_form_type }
        else
          format.html { render action: 'new' }
          format.json { render json: @dynamic_form_type.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /dynamic_form_types/1
    # PATCH/PUT /dynamic_form_types/1.json
    def update
      if params[:save_as_button]
          # Strip out ids from old form
          # todo: DynamicFormType.sanitize_fields_before_dupe(fields) ??
          dynamic_form_type_params['fields_attributes'].each do |field|
              field[1].delete('id')
          end
          @dynamic_form_type = DynamicFormType.new(dynamic_form_type_params)
          @dynamic_form_type.user_id = current_user.id 
          if @dynamic_form_type.save
              redirect_to @dynamic_form_type, notice: 'Your new form has been saved.'
          else
              render action: 'edit'
          end
      elsif @dynamic_form_type.update(dynamic_form_type_params)
          redirect_to @dynamic_form_type, notice: 'Dynamic form type was successfully updated.'
      else
          render action: 'edit'
      end
    end

    # DELETE /dynamic_form_types/1
    # DELETE /dynamic_form_types/1.json
    def destroy
      @dynamic_form_type.destroy
      respond_to do |format|
        format.html { redirect_to dynamic_form_types_url }
        format.json { head :no_content }
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_dynamic_form_type
        @dynamic_form_type = DynamicFormType.find(params[:id])
      end

      def non_editable_dynamic_forms
        if current_user.id != @dynamic_form_type.user_id 
          redirect_to(root_path, alert: 'Error: You can only view your own Dynamic forms' )
        end
      end
      # Never trust parameters from the scary internet, only allow the white list through.
      def dynamic_form_type_params
        params.require(:dynamic_form_type).permit(:name, :user_id, :description, :form_type,:is_public).tap do |whitelisted|
          whitelisted[:fields_attributes] = params[:dynamic_form_type][:fields_attributes] if !params[:dynamic_form_type][:fields_attributes].blank?
        end
      end

      
  end
end
