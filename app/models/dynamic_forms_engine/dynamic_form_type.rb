module DynamicFormsEngine
  class DynamicFormType < ActiveRecord::Base
  	has_many :fields, class_name: "DynamicFormField",  :dependent => :destroy
    has_many :entries, class_name: "DynamicFormEntry"

    accepts_nested_attributes_for :fields, allow_destroy: true

    validates :name, :description, :fields, presence: true
    validates :form_type, presence: true, :inclusion => { :in => %w(Default-form Multi-step), 
                                                      :message => "%{value} is not a valid choice" }
    validate :field_group_requirement, :other_option_validate, :field_group_order, :public_form, :field_size

    def field_size
      self.fields.each do |field|
        if field.field_type == "contacts" && !field.included_in_report == "false"
          errors.add field.name, "Contacts field has a fixed width"
        elsif field.field_type == "divider" && !field.included_in_report == "false"
         errors[:base] << "Divider field has a fixed width"
        elsif field.field_type == "field_group" && !field.included_in_report == "false"
          errors.add field.name, "Field_group field has a fixed width"
        elsif field.field_type == "signature" && !field.included_in_report == "false"
          errors.add field.name, "Signature field has a field has a fixed width"
        elsif field.field_type == "spacer" && !field.included_in_report == "false"
           errors[:base] << "Spacer field has a field has a fixed width"
        end 
      end
    end

    def include_option
      self.fields.each  do |field|
        if field.field_type == "contacts" && include_field.included_in_report
          errors.add field.name, "Contacts cannot be included in report"
        elsif field.field_type == "divider" && include_field.included_in_report
          errors[:base] << "Divider field cannot be included in report"
        elsif field.field_type == "field_group" && include_field.included_in_report
          errors.add field.name, "Field group cannot be included in report"
        elsif field.field_type == "file_upload" && include_field.included_in_report
          errors.add field.name, "File upload cannot be included in report"
        elsif field.field_type == "large_header" && include_field.included_in_report
          errors.add field.name, "Large header cannot be included in report"
        elsif field.field_type == "medium_header" && include_field.included_in_report
          errors.add field.name, "Medium header cannot be included in report"
        elsif field.field_type == "medium_header" && include_field.included_in_report
          errors.add field.name, "Small header cannot be included in report"
        elsif field.field_type == "spacer" && include_field.included_in_report
          errors[:base] << "Spacer field cannot be included in report"
        end
      end
    end
    
    def public_form
      if self.is_public
        self.fields.each do |check_field|
          if check_field.field_type == "contacts" || check_field.field_type == "file_upload"
            errors.add check_field.name, "A public form cannot have a Contacts or file upload field"
          end
        end
      end
    end

    def field_group_order
      self.fields.each_with_index do |item, index|
        if item.field_type == "field_group" 
          if fields[index+1].nil?
            errors.add(item.name,"field group must have at least one field in it!!", { :id => 12 })
          elsif !fields[index+1].nil? && fields[index+1].field_type =="field_group"
            errors.add item.name, "You cannot have two field groups next to each other"
          end
        end
      end
    end


    def field_group_requirement
      if self.form_type == "Multi-step"
        field_group_size = 0
        self.fields.each do |check_field|
          if check_field.field_type == "field_group"
            field_group_size += 1
          end
        end
        if field_group_size < 2
          errors[:base] << "You must select at least 2 field groups for a Multi-step form"
          return false
        end
      end
    end

    def ordered_fields
      fields.order("field_order ASC")
    end

    #checks to see if user deleted other option 
    def other_option_validate
      self.fields.each do |check_field|
        if check_field.field_type == "options_select_with_other"
          unless check_field.content_meta =~ /(,Other)/
            check_field.content_meta << ",Other"
          end
        end
      end
    end

    def is_multistep_form
      true if form_type === "Multi-step"
    end

    def is_default_form
      true if form_type === "Default-form"
    end


    #
    # SELF
    #
    def self.field_types
      ['agreement', 'calendar', 'check_box', 'contacts', 'currency', 'description', 
        'divider', 'email_validation', 'field_group', 'file_upload', 'large_header', 
        'medium_header', 'options_select', 'options_select_with_other', 'phone_validation', 
        'signature', 'small_header', 'spacer', 'text_area', 'text_field']
    end
    
  end
end
