module DynamicFormsEngine
  class DynamicFormField < ActiveRecord::Base
    cattr_accessor :field_choices, instance_writer: false
    cattr_accessor :field_with_null_value, instance_writer: false

    @@field_choices = ["agreement", "calendar", "check_box", "contacts", "currency", "short_description", "divider", "email_validation", "field_group", 
                      "file_upload", "large_header","long_description", "medium_header", "options_select", "options_select_with_other","options_select_with_us_states", 
                       "phone_validation", "signature","small_header", "social_security", "spacer", "text_area", "text_field"]
    @@default_field_width = ["contacts","divider","field_group","large_header","medium_header","small_header","signature","spacer"]
    @@field_width_choices = ["false","3","4","5","6","8","12"]
    @@field_with_null_value = ["short_description","divider","field_group","large_header","long_description","medium_header","spacer"]

  	belongs_to :dynamic_form_type
    # has_many :attachments, :as => :attachable, :dependent => :destroy
    # accepts_nested_attributes_for :attachments, :allow_destroy => :true, reject_if: proc { |attributes| attributes["filename"].nil? }

    validates :field_type, presence: true
    validates :name, presence: true, if: :field_name_required?
    validates :field_width, inclusion: { in: @@field_width_choices, message: "%{value} is not a valid field width!" }
    validates :field_type, inclusion: { in: @@field_choices, message: "%{value} is not a valid field type!" }
    validate  :in_report, :field_name, :is_required, on: :create 
    validate  :other_option
    
    before_save :set_field_width

    def self.default_width
      @@default_field_width.delete("signature")
      @@default_field_width
    end

    def field_name_required?
      req_name_fields = @@field_choices.reject { |field| field == "divider" || field == "spacer" || field == "long_description" || field == "short_description" }
      if name.blank? && req_name_fields.include?(field_type)
        return true
      end
    end

    def in_report
      field = field_type
      error_msg = field + ' field cannot be included in report'
      if self.included_in_report && @@default_field_width.include?(field) 
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
      elsif field == "field_group" && self.name.empty?
        errors.add field, 'Field group need to have names'
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

      def set_field_width
        if self.field_width == "false" && !@@default_field_width.include?(self.field_type)
          self.field_width = "6"
        elsif @@default_field_width.include?(self.field_type)
          self.field_width = "12"
        end
      end

  end
end
