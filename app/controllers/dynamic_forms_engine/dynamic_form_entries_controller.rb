require_dependency "dynamic_forms_engine/application_controller"

module DynamicFormsEngine
  class DynamicFormEntriesController < ApplicationController
    before_action :set_dynamic_form_entry, only: [:show, :edit, :update, :destroy]
    before_filter :authenticate_user!

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

    # GET /dynamic_form_entries/1
    # GET /dynamic_form_entries/1.json
    def show
      #@contacts = []#Contact.where(id: Contactable.select(:contact_id).where(:contactable_type => "DynamicFormEntry",:contactable_id => params[:id]))
    end

    # GET /dynamic_form_entries/new
    def new
      @dynamic_form_type    = DynamicFormType.find(params[:dynamic_form_type_id])
      @dynamic_form_entry   = current_user.dynamic_form_entries.new(dynamic_form_type_id: params[:dynamic_form_type_id]) 

      #DynamicFormEntry.new(dynamic_form_type_id: params[:dynamic_form_type_id])

    end
    # GET /dynamic_form_entries/1/edit
   

    # POST /dynamic_form_entries
    # POST /dynamic_form_entries.json
    def create

      @dynamic_form_type  = DynamicFormType.find(params[:dynamic_form_entry][:dynamic_form_type_id])
      @dynamic_form_entry = current_user.dynamic_form_entries.new(dynamic_form_entry_params)
      if params[:signature]
        @dynamic_form_entry.signature = params[:signature]
      end

      if params[:save_draft]
        @dynamic_form_entry.in_progress = true
      else 
        @dynamic_form_entry.in_progress = false
      end
      # checks to see if contact exists for the current user
      #@dynamic_form_entry.save_new_contacts(current_user)
      #check to see if user selected only contacts and or signature field
      if !@dynamic_form_entry.properties.nil? && @dynamic_form_entry.valid?
        @dynamic_form_entry.properties.each_pair do |property_id, property_value|
          field = @dynamic_form_type.fields.find(property_id)

          if field.attachment?
            new_id = DynamicFormEntry.last.id+1
            i = 0
            attachments = property_value.size
            while i < attachments
              file_attachment = Attachment.create!(attachable_id: new_id,
                                                user_id: current_user.id,
                                                attachable_type: 'DynamicFormEntry',
                                                content_name: field.name, 
                                                filename: property_value[i])
              i += 1
  
            end
            @dynamic_form_entry.properties[property_id] = file_attachment.id

          end
        end
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
        @dynamic_form_entry.in_progress = false
      end

      dynamic_form_entry_params[:properties].each_pair do |property_id, property_value|
          field = @dynamic_form_type.fields.find(property_id)
          
          if field.attachment?
            raise
            @dynamic_form_entry.properties[1][:type]
            Attachment.update!()
          end
      end
      
      if params[:submit_entry] && @dynamic_form_entry.update(dynamic_form_entry_params)
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

    # Use callbacks to share common setup or constraints between actions.
    def set_dynamic_form_entry
      @dynamic_form_entry = current_user.dynamic_form_entries.where( :id => params[:id] ).first
      #DynamicFormEntry.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def dynamic_form_entry_params
      params.require(:dynamic_form_entry).permit(:dynamic_form_type_id,:signature,:in_progress,:contacts_attributes => [:phone, :contact_type,:user_id, :first_name, :company,:email,:uuid]).tap do |whitelisted|
        whitelisted[:properties] = params[:dynamic_form_entry][:properties]
      end
    end
  end
end
