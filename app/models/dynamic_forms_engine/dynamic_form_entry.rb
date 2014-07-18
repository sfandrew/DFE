module DynamicFormsEngine
  class DynamicFormEntry < ActiveRecord::Base
  	belongs_to :dynamic_form_type
    belongs_to :user

    # before_create :save_new_contacts

    serialize :properties, Hash
    # validate :validate_properties

    def validate_properties
      # Rails.logger.warn "\n\nproperties hash: #{properties}\n\n"
      dynamic_form_type.fields.each do |field|
        # Rails.logger.warn "\n\nfield: #{field.name} properties[field]: #{properties[field.name]}\n\n"
        if field.required? && properties[field.name].blank?

          errors.add field.name, "must not be blank"
        end
      end
    end

    # def save_new_contacts
    #   # binding.pry
    #   if contacts.size > 0
    #     unique_contacts = UniqueContacts.new(user, contacts)

    #     self.contacts = unique_contacts.uniq

    #   end
    # end

    def each_field_with_value
      properties.each_pair do |id, value|
        field = self.dynamic_form_type.fields.find(id)
        if field.attachment?
          attachment_id = value
          attachment = Attachment.find(attachment_id)
          yield field, attachment
        else
          yield field, value
        end
      end
    end
  end
end
