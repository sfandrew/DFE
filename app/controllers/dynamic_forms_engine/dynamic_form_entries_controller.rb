require_dependency "dynamic_forms_engine/application_controller"

module DynamicFormsEngine
  class DynamicFormEntriesController < ApplicationController
    before_action :set_dynamic_form_entry, only: [:show, :edit, :update, :destroy]
    # before_action :public_form, only: [:new, :create, :show], if: -> { current_user.nil? }
    before_action :set_dynamic_form_type, only: [:new, :create, :show, :form_entries, :edit, :update]

    def index
      if !params[:search].blank?
        @dynamic_form_entries = current_user.dynamic_form_entries.search(params[:search]).order(updated_at: :desc)
      elsif current_user.authorized_users? && params[:user].present?
        @dynamic_form_entries = DynamicFormEntry.where(:user => params[:user]).order(updated_at: :desc)
      else
        @dynamic_form_entries = current_user.dynamic_form_entries.order(updated_at: :desc)
      end
      @dynamic_form_entries = @dynamic_form_entries.includes(:dynamic_form_type).paginate(:page => params[:page], :per_page => 30)
      @entries_name = @dynamic_form_entries.map { |form_entry| [form_entry.dynamic_form_type.name, form_entry.dynamic_form_type.id] }.uniq unless @Dynamic_form_entries.blank?
      respond_to do |format|
        format.print { render "index.html.erb" }
      end
    end

    def form_entries
      @dynamic_form_entries   = current_user.dynamic_form_entries.where(:dynamic_form_type_id =>  @dynamic_form_type.id).all
      @entries_name = @dynamic_form_entries.map { |form_entry| [form_entry.dynamic_form_type.name, form_entry.dynamic_form_type.id] }.uniq
      respond_to do |format|
        format.html
        format.print { render "form_entries.html.erb" }
        format.csv { render text: DynamicFormEntry.entries_to_csv(@dynamic_form_entries, @dynamic_form_type)}
        format.xml {
          @array_for_xml = DynamicFormEntry.entries_to_array(@dynamic_form_entries, @dynamic_form_type)
          stream = render_to_string(:template => "dynamic_forms_engine/dynamic_form_entries/show.xml.erb")
          send_data(stream, :type => "text/xml", :filename => "form_entries.xml")
        }
      end
    end

    def show

      respond_to do |format|
        format.html
        format.print { render "show_application.print" }
        format.csv { render text: @dynamic_form_entry.to_csv }
        format.xml { @array_for_xml = @dynamic_form_entry.to_array}
      end
    end

    def new
      if current_user
        @dynamic_form_entry = current_user.dynamic_form_entries.new(dynamic_form_type_id: @dynamic_form_type.id)
      else
        @dynamic_form_entry = DynamicFormEntry.new(dynamic_form_type_id: @dynamic_form_type.id)
      end
    end

    def create
      #non public form
      if current_user
        @dynamic_form_entry = current_user.dynamic_form_entries.new(dynamic_form_entry_params)
      else
        @dynamic_form_entry = DynamicFormEntry.new(dynamic_form_entry_params)
      end

      params[:save_draft] ? @dynamic_form_entry.in_progress = true : @dynamic_form_entry.in_progress = false

      build_attachments_and_delete

      if @dynamic_form_entry.save
        if params[:submit_entry]
          @dynamic_form_entry.create_pdf(@dynamic_form_entry, @building_apartments)
          FormEntryMailer.email_entry(@dynamic_form_entry).deliver
          FormEntryMailer.claridge_notification.deliver if @dynamic_form_entry.is_claridge_app?
          redirect_to dynamic_form_entry_path(@dynamic_form_entry) + "?iframe=" + (params[:iframe] == "1" ? "1" : "0"), notice: "<strong>You have submitted your form entry!</strong>".html_safe
        else
          if params[:email_recipient]
            @dynamic_form_entry.create_pdf(@dynamic_form_entry, @building_apartments)
            FormEntryMailer.email_entry(@dynamic_form_entry).deliver
          end
          redirect_to edit_dynamic_form_entry_path(@dynamic_form_entry) + "?iframe=" + (params[:iframe] == "1" ? "1" : "0"), alert: "<strong> You have temporary saved your draft. Come back to submit it when ready!</strong>".html_safe
        end
      else
        @dynamic_form_entry.format_properties
        render "new"
      end

    end

    def edit
      redirect_to dynamic_form_entries_path, alert: 'You cannot edit your application once submitted' unless @dynamic_form_entry.in_progress
      @file_upload = current_user.dynamic_form_entries.where(:id => params[:id]).first
    end

    def update
      respond_to do |format|
        format.json {  
            update_section_tab_via_ajax
            render text: "success"
        }
        format.html {
          if params[:save_draft]
            @dynamic_form_entry.in_progress = true
          else
            @dynamic_form_entry.assign_attributes(dynamic_form_entry_params)
            @dynamic_form_entry.in_progress = false
          end

          build_attachments_and_delete

          if @dynamic_form_entry.update_attributes(dynamic_form_entry_params)
            if params[:submit_entry]
              @dynamic_form_entry.create_pdf(@dynamic_form_entry, @building_apartments)
              FormEntryMailer.email_entry(@dynamic_form_entry).deliver
              FormEntryMailer.claridge_notification.deliver if @dynamic_form_entry.is_claridge_app?
              redirect_to @dynamic_form_entry, notice: 'Below is your curent Form Entry Submission!'
            else
              if params[:email_recipient]
                @dynamic_form_entry.create_pdf(@dynamic_form_entry, @building_apartments)
                FormEntryMailer.email_entry(@dynamic_form_entry).deliver
              end
              redirect_to edit_dynamic_form_entry_path(@dynamic_form_entry), alert: "<strong> You have temporary saved your draft. Come back to submit it when ready!</strong>".html_safe
            end
          else
            @dynamic_form_entry.assign_attributes(dynamic_form_entry_params)
            @dynamic_form_entry.format_properties
            render "edit"
          end
        }
      end

    end

    def destroy
      @dynamic_form_entry.destroy
      respond_to do |format|
        format.html { redirect_to dynamic_form_entries_url }
        format.json { head :no_content }
      end
    end

    private

    def build_attachments_and_delete
    # builds new attachments
      dynamic_form_entry_params[:attachments_attributes].each do |key, value|
        next if value[:filename_cache].blank?
        if value[:id].empty?
          attachment = @dynamic_form_entry.attachments.build(value)
          attachment.filename = File.open(File.join(Rails.root, "public", value[:filename_cache]))
        end
        # deletes attachments
        if value[:remove_filename] == "1"
          if value[:id].empty?
            attachment.remove_filename!
          else
            @dynamic_form_entry.attachments.find(value[:id]).delete #deletes from attachments
            params[:dynamic_form_entry][:attachments_attributes].delete(key) #deletes from params
          end
        end
      end
    end

    def update_section_tab_via_ajax
       @dynamic_form_entry.update_column(:last_section_saved, dynamic_form_entry_params[:last_section_saved])
    end

    def public_form
      set_dynamic_form_type unless @dynamic_form_type
    end

    # Since dynamic_form_type_id is set in different places depending on the action, we have to check a few places
    def set_dynamic_form_type
      set_dynamic_form_entry unless @dynamic_form_entry
      if params[:dynamic_form_type_id]
        @dynamic_form_type = DynamicFormType.find(params[:dynamic_form_type_id])
      elsif params[:dynamic_form_entry] && params[:dynamic_form_entry][:dynamic_form_type_id]
        @dynamic_form_type = DynamicFormType.find(params[:dynamic_form_entry][:dynamic_form_type_id])
      elsif @dynamic_form_entry
        @dynamic_form_type = @dynamic_form_entry.dynamic_form_type
      else
        redirect_to(root_path, alert: "Could not find Dynamic Form Type.")
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_dynamic_form_entry
      if current_user.authorized_users?
        @dynamic_form_entry = DynamicFormEntry.where(:id => params[:id]).first
      else
        @dynamic_form_entry = current_user.dynamic_form_entries.where( :id => params[:id] ).first || DynamicFormEntry.find_by_uuid(params[:id])
      end

    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def dynamic_form_entry_params
      params.require(:dynamic_form_entry).permit(:dynamic_form_type_id,:signature,:last_section_saved, :in_progress, :application_pdf, :attachments_attributes => [:id, :content_name,:filename, :filename_cache, :remove_filename,:content_meta],
        :contacts_attributes => [:phone, :contact_type,:user_id, :first_name, :company,:email,:uuid]).tap do |whitelisted|
        whitelisted[:properties] = params[:dynamic_form_entry][:properties]
      end
    end
  end
end
