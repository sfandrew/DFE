module DynamicFormsEngine
  class DynamicFormType < ActiveRecord::Base
  	has_many :fields, class_name: "DynamicFormField",  :dependent => :destroy
    has_many :entries, class_name: "DynamicFormEntry"

    accepts_nested_attributes_for :fields, allow_destroy: true

    #validates :name, :description, :fields, presence: true
    #validates :form_type, presence: true, :inclusion => { :in => %w(Default-form Multi-step), 
                                                      :message => "%{value} is not a valid choice" }
    #validate :field_group_requirement, :field_group_order, :public_form, :contact_field_limit
 
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
      self.ordered_fields.each_with_index do |item, index|
        if item.field_type == "field_group" 
          if ordered_fields[index+1].nil?
            errors.add(item.name,"field group must have at least one field in it!!", { :id => 12 })
          elsif !ordered_fields[index+1].nil? && ordered_fields[index+1].field_type =="field_group"
            errors.add item.name, "You cannot have two field groups next to each other"
          end
        elsif index == 0 && self.form_type == "Multi-step" && item.field_type != "field_type"
          errors.add(item.name, "first field must be a field group!")
        end
      end
    end

    def contact_field_limit
      contact_fields = 0
      self.fields.each do |check_field|
        contact_fields += 1 if check_field.field_type == "contacts"
      end
      errors.add(:base, "You can only include one contact field") if contact_fields > 1 
    end

    def field_group_requirement
      multi_step = true if self.form_type == "Multi-step"
      field_group_size = 0
      self.fields.each do |check_field|
        field_group_size += 1 if check_field.field_type == "field_group"
      end
      if multi_step && field_group_size < 2
        errors.add(:base, "You must select at least 2 field groups for a Multi-step form")
      end
    end

    def ordered_fields
      #fields.order("field_order ASC")
      fields.sort_by { |x| x.field_order }
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

    
  end
end
