module DynamicFormsEngine
  class DynamicFormField < ActiveRecord::Base
  	belongs_to :dynamic_form_type
    validates  :field_type, presence: true
    validates :field_type , inclusion: { 
                                        in: ["agreement", "calendar", "check_box", "contacts", "currency", "description", 
                                            "divider", "email_validation", "field_group", "file_upload", "large_header", "medium_header", 
                                            "options_select", "options_select_with_other", "phone_validation", "signature", "small_header", 
                                            "spacer", "text_area", "text_field"],
                                          message: "%{value} is not a valid choice!" 
                                        }
    validates_presence_of :name, if: :divider_spacer_fields
    

    def divider_spacer_fields
    	if self.field_type == 'divider' && !self.name.blank? || self.field_type == 'spacer' && !self.name.blank?
    		errors[:attribute] << 'Divider or Spacer cannot contain a name!'
    		return false
    	end   
    end
    
    def attachment?
      field_type.to_s == 'file_upload'
    end
  end
end
