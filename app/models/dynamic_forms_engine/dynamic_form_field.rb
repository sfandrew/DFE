module DynamicFormsEngine
  class DynamicFormField < ActiveRecord::Base
  	belongs_to :dynamic_form_type
    validates :name, :field_type, presence: true
    
    def attachment?
      field_type.to_s == 'file_upload'
    end
  end
end
