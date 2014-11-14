module DynamicFormsEngine
  class DynamicFormType < ActiveRecord::Base
  	has_many :fields, class_name: "DynamicFormField",  :dependent => :destroy
    has_many :entries, class_name: "DynamicFormEntry"

    accepts_nested_attributes_for :fields, allow_destroy: true

    validates :name, :description, :fields, presence: true
    validates :form_type, presence: true, :inclusion => { :in => %w(Default-form Multi-step), 
                                                      :message => "%{value} is not a valid choice" }
    validate :field_group_requirement, :field_group_order, :public_form
 
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
        elsif index == 0 && self.form_type == "Multi-step" && item.field_type != "field_type"
          errors.add(item.name, "first field must be a field group!")
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
