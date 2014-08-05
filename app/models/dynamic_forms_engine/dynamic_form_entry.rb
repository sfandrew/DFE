module DynamicFormsEngine
  class DynamicFormEntry < ActiveRecord::Base
  	belongs_to :dynamic_form_type
    belongs_to :user

    # before_create :save_signature

    serialize :properties, Hash

    validate :validate_email_phone_currency

    before_create :format_properties

   # http://stackoverflow.com/questions/8634139/phone-validation-regex
   # This should be run before format_properties, so it relies on original properties format
    def validate_email_phone_currency
      if dynamic_form_type.fields
        dynamic_form_type.fields.each do |field|
          if field.field_type == "email_validation"
            unless self.properties[field.id.to_s] =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
              errors[:base] << "Not a valid email!"
            end
          elsif field.field_type == "phone_validation"
            unless self.properties[field.id.to_s] =~ /(?:(?:\+?1\s*(?:[.-]\s*)?)?(?:(\s*([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9]‌​)\s*)|([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9]))\s*(?:[.-]\s*)?)([2-9]1[02-9]‌​|[2-9][02-9]1|[2-9][02-9]{2})\s*(?:[.-]\s*)?([0-9]{4})\s*(?:\s*(?:#|x\.?|ext\.?|extension)\s*(\d+)\s*)?$/
              errors[:base] << "Enter a valid phone number including area code!"
            end
          elsif field.field_type == "currency"
            unless self.properties[field.id.to_s] =~ /\A\d+(?:\.\d{0,2})?\z/
              errors[:base] << "Enter a valid amount!"
            end
          elsif field.field_type == "agreement"
            unless self.properties[field.id.to_s] == "1"
              errors[:base] << "You must agree to the form before you can submit!"
            end
          end
        end
      end
    end
    
    #appends string 'other' if other option was selected
    def other_option
      if dynamic_form_type.fields
        dynamic_form_type.fields.each do |field|
          if field.field_type == "options_select_with_other" && !field.content_meta.include?(self.properties[field.id.to_s])
            self.properties[field.id.to_s].insert(0,'Other: ')
          end
        end
      end
    end
    
    def save_new_contacts(current_user)
      if self.contacts
        current_user_contact_emails = current_user.contacts.pluck(:email)
        self.contacts.each do |contact|
          contact.set_user_id(self.user_id)
          if current_user_contact_emails.include?(contact.email)
            self.contacts << current_user.contacts.where(email: contact.email).first
            self.contacts.delete(contact)
            #delete new contact row if these fields are empty
          elsif contact.id.nil? && contact.first_name.empty? && contact.contact_type.empty? && contact.email.empty? && contact.company.empty?
            self.contacts.delete(contact)
          end
        end
      end
    end


    def each_field_with_value
      properties.each do |index, field|
        if field[:type].to_s == 'file_upload'
          attachment_id = value
          attachment = Attachment.find(attachment_id)
          yield index, attachment
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
        new_properties[index] = {name: field.name, type: field.field_type, value: field_value}
      end
      self.properties = new_properties
    end
  end

  def search(terms)
    puts "\n\n\n\ Is this working? \n\n\n"
    search_query = DynamicFormsEngine::DynamicFormEntry.includes(:dynamic_form_type).where(:user_id => self.user.id)

    if(!terms[:terms].blank?)
      search_query = DynamicFormsEngine::DynamicFormEntry.includes(:dynamic_form_type).where(:user_id => self.user.id).order("#{terms[:order_by]} #{terms[:order]}")
    end

    if !terms[:name].blank?
      search_query = search_query.where(:dynamic_form_type_id => terms[:name])
    end

    if !terms[:properties].blank?
      search_query = search_query.where("Properties like ?", terms[:property])
    end

    
  end

end
