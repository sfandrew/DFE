module DynamicFormsEngine
  class DynamicFormField < ActiveRecord::Base
  	belongs_to :dynamic_form_type
    validates  :field_type, presence: true
    validates_presence_of :name, if: :divider_spacer_fields

    def divider_spacer_fields
    	if self.field_type == 'divider' && !self.name.blank?
    		errors[:attribute] << 'Divider or Spacer cannot contain a name!'
    		return false
    	end   
    end
    
    def attachment?
      field_type.to_s == 'file_upload'
    end
  end
end
