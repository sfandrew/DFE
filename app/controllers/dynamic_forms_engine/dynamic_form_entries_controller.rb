require_dependency "dynamic_forms_engine/application_controller"

module DynamicFormsEngine
  class DynamicFormEntriesController < ApplicationController
    before_action :set_dynamic_form_entry, only: [:show, :edit, :update, :destroy]
    before_filter :authenticate_user!, only: [:index,:destroy, :edit, :update]
    before_action :public_form, only: [:new, :create, :show], if: -> { current_user.nil? }

    # GET /dynamic_form_entries
    # GET /dynamic_form_entries.json
    def index
      @dynamic_form_entries = current_user.dynamic_form_entries.all #DynamicFormEntry.all
      @entries_name = @dynamic_form_entries.map { |form_entry| [form_entry.dynamic_form_type.name, form_entry.dynamic_form_type.id] }
      if !params[:search].blank?
        @dynamic_form_entries = current_user.dynamic_form_entries.search(params[:search])
      end
    end

    def form_entries
      @dynamic_form_type      = DynamicFormType.find(params[:dynamic_form_type_id])
      @dynamic_form_entries   = current_user.dynamic_form_entries.where(:dynamic_form_type_id =>  @dynamic_form_type.id).all
      @entries_name = @dynamic_form_entries.map { |form_entry| [form_entry.dynamic_form_type.name, form_entry.dynamic_form_type.id] }
      render action: 'index'
    end

    def show
    end

    def new
      @dynamic_form_type    = DynamicFormType.find(params[:dynamic_form_type_id])
      current_user.nil? ? public_form :  @dynamic_form_entry = current_user.dynamic_form_entries.new(dynamic_form_type_id: params[:dynamic_form_type_id])
    end

    def create
      @dynamic_form_type  = DynamicFormType.find(params[:dynamic_form_entry][:dynamic_form_type_id])
      current_user.nil? ? public_form : @dynamic_form_entry = current_user.dynamic_form_entries.new(dynamic_form_type_id: params[:dynamic_form_type_id])

      if params[:signature]
        @dynamic_form_entry.signature = params[:signature]
      end

      if params[:save_draft]
        @dynamic_form_entry.in_progress = true
      else 
        @dynamic_form_entry.in_progress = false
      end

      if params[:submit_entry] && @dynamic_form_entry.save
        redirect_to dynamic_form_entry_path(@dynamic_form_entry), notice: "<strong>You have submitted your form entry!</strong>".html_safe
      elsif params[:save_draft] && @dynamic_form_entry.save
        redirect_to edit_dynamic_form_entry_path(@dynamic_form_entry), alert: "<strong> You have temporary saved your draft. Come back to submit it when ready!</strong>".html_safe
      else       
        @dynamic_form_entry.format_properties
        render "new"
      end
    end
     def edit
      @dynamic_form_type = @dynamic_form_entry.dynamic_form_type

    end

    def update
      @dynamic_form_type = @dynamic_form_entry.dynamic_form_type

      if params[:signature]
        @dynamic_form_entry.signature = params[:signature]
      end
      if params[:save_draft]
        @dynamic_form_entry.in_progress = true
      else 
        @dynamic_form_entry.assign_attributes(dynamic_form_entry_params)
        @dynamic_form_entry.in_progress = false
      end
      
      if params[:submit_entry] && @dynamic_form_entry.save
        redirect_to @dynamic_form_entry, notice: 'Below is your curent Form Entry Submission!'
      elsif params[:save_draft] && @dynamic_form_entry.update(dynamic_form_entry_params)
        redirect_to edit_dynamic_form_entry_path(@dynamic_form_entry), alert: "<strong> You have temporary saved your draft. Come back to submit it when ready!</strong>".html_safe 

      else
        # @dynamic_form_entry.assign_attributes(dynamic_form_entry_params)
        @dynamic_form_entry.format_properties
        render "edit"
      end

    end

    # DELETE /dynamic_form_entries/1
    # DELETE /dynamic_form_entries/1.json
    def destroy
      @dynamic_form_entry.destroy
      respond_to do |format|
        format.html { redirect_to dynamic_form_entries_url }
        format.json { head :no_content }
      end
    end

    private

    def public_form
      #on new
      if !params[:dynamic_form_type_id].nil? && DynamicFormsEngine::DynamicFormType.find(params[:dynamic_form_type_id]).is_public == true
        @dynamic_form_entry = DynamicFormsEngine::DynamicFormEntry.new(dynamic_form_type_id: params[:dynamic_form_type_id])
      #on create
      elsif !params[:dynamic_form_entry].nil? && DynamicFormsEngine::DynamicFormType.find(params[:dynamic_form_entry][:dynamic_form_type_id]).is_public == true
        @dynamic_form_entry = DynamicFormsEngine::DynamicFormEntry.new(dynamic_form_entry_params)
      #on show
      elsif !@dynamic_form_entry.nil? 
        true if @dynamic_form_entry.dynamic_form_type.is_public == true 
      else 
        redirect_to(root_path, alert: 'You must be signed in!')
      end
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_dynamic_form_entry
      if current_user.nil?
        @dynamic_form_entry = DynamicFormsEngine::DynamicFormEntry.where(:id => params[:id]).first
      else
        @dynamic_form_entry = current_user.dynamic_form_entries.where( :id => params[:id] ).first
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def dynamic_form_entry_params
      params.require(:dynamic_form_entry).permit(:dynamic_form_type_id,:signature,:in_progress,:contacts_attributes => [:phone, :contact_type,:user_id, :first_name, :company,:email,:uuid]).tap do |whitelisted|
        whitelisted[:properties] = params[:dynamic_form_entry][:properties]
      end
    end
  end
end