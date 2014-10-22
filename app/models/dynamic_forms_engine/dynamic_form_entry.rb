module DynamicFormsEngine
  class DynamicFormEntry < ActiveRecord::Base
  	belongs_to :dynamic_form_type
    belongs_to :user

    serialize :properties, Hash

    validate :in_progress_validation, :if => Proc.new { |properties| properties.in_progress == true }
    validate :validate_on_submit, :if => Proc.new { |properties| properties.in_progress != true}
    before_create :format_properties, :if => Proc.new { |properties| !properties.properties.nil? }
    before_update :format_properties, :if => Proc.new { |properties| !properties.properties.nil? }


    def get_property_value(field_id)
      if !properties.blank?
        temp = properties.find { |key, value|  value[:id].to_i == field_id }
        temp[1][:value] if temp && temp[1]
      end
    end

    def in_progress_validation
      dynamic_form_type.fields.each do |field|
        if field.field_type == "email_validation" && !self.properties[field.id.to_s].blank?
          unless self.properties[field.id.to_s] =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
            errors.add field.name, "Not a valid email!"
          end
        elsif field.field_type == "phone_validation" && !self.properties[field.id.to_s].blank?
          unless self.properties[field.id.to_s] =~ /(?:(?:\+?1\s*(?:[.-]\s*)?)?(?:(\s*([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9]‌​)\s*)|([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9]))\s*(?:[.-]\s*)?)([2-9]1[02-9]‌​|[2-9][02-9]1|[2-9][02-9]{2})\s*(?:[.-]\s*)?([0-9]{4})\s*(?:\s*(?:#|x\.?|ext\.?|extension)\s*(\d+)\s*)?$/
            errors.add field.name, "Enter a valid phone number including area code!"
          end
        elsif field.field_type == "currency" && !self.properties[field.id.to_s].blank?
          unless self.properties[field.id.to_s] =~ /\A\d+(?:\.\d{0,2})?\z/
            errors.add field.name, "Enter a valid amount!"
          end
        elsif field.field_type == "agreement" && !self.properties[field.id.to_s] != "0"
          unless self.properties[field.id.to_s] == "1"
            errors.add field.name, "You must agree to the form before you can submit!"
          end
        end
      end
    end

   # http://stackoverflow.com/questions/8634139/phone-validation-regex
    def validate_on_submit
      
      #binding.pry

      if dynamic_form_type.fields

        dynamic_form_type.fields.each do |field|
          if field.field_type == "email_validation"
            unless self.properties[field.id.to_s] =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
              errors.add field.name, "Not a valid email!"
            end
          elsif field.field_type == "phone_validation"
            unless self.properties[field.id.to_s] =~ /(?:(?:\+?1\s*(?:[.-]\s*)?)?(?:(\s*([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9]‌​)\s*)|([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9]))\s*(?:[.-]\s*)?)([2-9]1[02-9]‌​|[2-9][02-9]1|[2-9][02-9]{2})\s*(?:[.-]\s*)?([0-9]{4})\s*(?:\s*(?:#|x\.?|ext\.?|extension)\s*(\d+)\s*)?$/
              errors.add field.name, "Enter a valid phone number including area code!"
            end
          elsif field.field_type == "currency"
            unless self.properties[field.id.to_s] =~ /\A\d+(?:\.\d{0,2})?\z/
              errors.add field.name, "Enter a valid amount!"
            end
          elsif field.field_type == "agreement"
            unless self.properties[field.id.to_s] == "1"
              errors.add field.name, "You must agree to the form before you can submit!"
            end
          elsif field.field_type == "signature" && field.required? &&  self.signature.size < 25
            errors.add field.name, "must not be blank"
          elsif field.field_type != "signature" && field.required? && properties[field.id.to_s].blank?
            errors.add field.name, "must not be blank"
          end
        end
      end
    end

    
    
    # def save_new_contacts(current_user)
    #   if self.contacts
    #     current_user_contact_emails = current_user.contacts.pluck(:email)
    #     self.contacts.each do |contact|
    #       contact.set_user_id(self.user_id)
    #       if current_user_contact_emails.include?(contact.email)
    #         self.contacts << current_user.contacts.where(email: contact.email).first
    #         self.contacts.delete(contact)
    #         #delete new contact row if these fields are empty
    #       elsif contact.id.nil? && contact.first_name.empty? && contact.contact_type.empty? && contact.email.empty? && contact.company.empty?
    #         self.contacts.delete(contact)
    #       end
    #     end
    #   end
    # end

    def each_field_with_value
      properties.each do |index, field|
        if field[:type].to_s == 'file_upload'
          attachment_id = field[:value]
          attachment = Attachment.find(attachment_id)
          field[:attachment] = attachment
          yield attachment, field
        else
          yield index, field
        end
      end
    end


    # Properties are initially saved as {"<field_id>" => "<field_value>"} 
    # However, relying on the original field object is bad because it might change
    #  This function transmutes the properties to a form that doesn't rely on the original field object
    # Should be run as before_create filter
    def format_properties
      old_properties = self.properties
      new_properties = {}
      old_properties.each_with_index do |(field_id, field_value), index|
        field = DynamicFormField.find(field_id.to_i)
        
        # Prepend "Other: " to options_select_with_other field types
        if field.field_type == "options_select_with_other" && !field.content_meta.include?(field_value)
          field_value = "Other: " + field_value
        end
        new_properties[index] = {name: field.name, type: field.field_type, value: field_value, id: field_id}
      end
      self.properties = new_properties
    end

    def self.search(terms)
      search_query = DynamicFormsEngine::DynamicFormEntry.includes(:dynamic_form_type)

      if(!terms[:terms].blank?)
        search_query = DynamicFormsEngine::DynamicFormEntry.includes(:dynamic_form_type).order("#{terms[:order_by]} #{terms[:order]}")
      end

      if !terms[:name].blank?
        search_query = search_query.where(:dynamic_form_type_id => terms[:name].to_i)
      end

      if !terms[:properties].blank?
        search_query = search_query.where("properties like ?", "%#{terms[:properties]}%")
      end

      if !terms[:start].blank? && !terms[:end].blank?
          date_start = Date.strptime(terms[:start], '%m/%d/%Y')
          date_end = Date.strptime(terms[:end], '%m/%d/%Y')
          search_query = search_query.where("created_at" => date_start..date_end)
      end
      return search_query
    end

    def to_array
      arr = []
      each_field_with_value do |index, field|
        arr_row = [field[:name]]
        case field[:type]
        when "phone_validation"
          arr_row << ActionController::Base.helpers.number_to_phone(field[:value])
        when "currency"
          arr_row << ActionController::Base.helpers.number_to_currency(field[:value])
        when "agreement"
          arr_row << "Approved"
        when "file_upload"
          arr_row << field[:value].filename.url
        else
          arr_row << field[:value]
        end
        arr << arr_row
      end
      return arr
    end

    def to_csv
      csv_string = ""
      to_array.each_with_index do |row|
        row.each_with_index do |col, index|
          csv_string += col
          csv_string += "," if index != (row.size-1)
        end
        csv_string += "\n"
      end
      return csv_string
    end

  end
end
