module DynamicFormsEngine
  class DynamicFormField < ActiveRecord::Base
  	belongs_to :dynamic_form_type
    validates  :field_type, presence: true
    validates :field_width, inclusion: { in: ["false","3","6","8","12"], message: "%{value} is not a valid choice!" }
    validates :field_type , inclusion: { 
                                        in: ["agreement", "calendar", "check_box", "contacts", "currency", "description", 
                                            "divider", "email_validation", "field_group", "file_upload", "large_header", "medium_header", 
                                            "options_select", "options_select_with_other", "phone_validation", "signature", "small_header", 
                                            "spacer", "text_area", "text_field"],
                                          message: "%{value} is not a valid choice!" 
                                        }
    validate :field_size, :in_report, :is_required, :field_name, :other_option
    before_save :valid_field_width


    def field_size
      field_width_val = ["3","6","8","12"]
      field = self.field_type
      error_msg = field + ' field has a fixed width'
      non_valid_fields =  ["contacts","divider","field_group","large_header","medium_header","small_header","signature","spacer"]
      if field_width_val.include?(self.field_width) && non_valid_fields.include?(field)
        errors.add field, error_msg
      end
    end

    def in_report
      field = self.field_type
      error_msg = field + ' field cannot be included in report'
      non_valid_fields = ["contacts","divider","field_group","large_header","medium_header","small_header",
                            "description","signature"]
      if self.included_in_report && non_valid_fields.include?(field)
        errors.add field, error_msg
      end
    end

    def is_required
      field = self.field_type
      error_msg = field + ' field cannot be required'
      non_valid_fields = ["divider","field_group","large_header","medium_header","small_header",
                            "description","spacer"]
      if self.required && non_valid_fields.include?(field)
        errors.add field, error_msg
      end
    end

    def field_name
      field = self.field_type
      error_msg = field + ' field cannot have a name'
      non_valid_fields = ["divider","spacer"]
      if !self.name.empty? && non_valid_fields.include?(field)
        errors.add field, error_msg
      end
    end
    
    #checks to see if user deleted other option 
    def other_option
      if self.field_type == "options_select_with_other"
        unless self.content_meta =~ /(,Other)/
          self.content_meta << ",Other"
        end
      end
    end

    def attachment?
      field_type.to_s == 'file_upload'
    end



    private 

      def valid_field_width
        field_width_val = ["3","6","8","12"]
        self.field_width = "6" if !field_width_val.include?(self.field_width)
      end

  end
end
