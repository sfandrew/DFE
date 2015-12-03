module DynamicFormsEngine
  class DynamicFormType < ActiveRecord::Base
  	has_many :fields, class_name: "DynamicFormField",  :dependent => :destroy
    has_many :entries, class_name: "DynamicFormEntry"

    belongs_to :user

    accepts_nested_attributes_for :fields, allow_destroy: true

    validates :name, :description, :fields, presence: true
    validates :form_type, presence: true, :inclusion => { :in => %w(Default-form Multi-step), 
                                                      :message => "%{value} is not a valid choice" }
    validate :field_group_requirement, :field_group_order, :public_form, :contact_field_limit, :multi_step_requirement

    def is_multi_step?
      form_type == 'Multi-step'
    end
 
    def public_form
      if is_public
        fields.each do |check_field|
          if check_field.field_type == "contacts" || check_field.field_type == "file_upload"
            errors.add check_field.name, "A public form cannot have a Contacts or file upload field"
          end
        end
      end
    end

    #makes sure that a field group has a field
    def field_group_order
      ordered_fields.each_with_index do |item, index|
        if item.field_type == "field_group" 
          if ordered_fields[index+1].nil?
            errors.add(item.name,"field group must have at least one field in it!")
          elsif !ordered_fields[index+1].nil? && ordered_fields[index+1].field_type =="field_group"
            errors.add item.name, "You cannot have two field groups next to each other"
          end
        end
      end
    end

    def multi_step_requirement
      ordered_fields.each_with_index do |field, index|
        if index == 0 && is_multistep_form && field.field_type != "field_group"
          errors.add item.name, "Multi step form must contain a field group as the first item"
        end
      end
    end

    #can only include 1 contact field
    def contact_field_limit
      contact_fields = 0
      self.fields.each do |check_field|
        contact_fields += 1 if check_field.field_type == "contacts"
      end
      errors.add(:base, "You can only include one contact field") if contact_fields > 1 
    end

    def field_group_requirement
      field_group_size = 0

      ordered_fields.each do |check_field|
        field_group_size += 1 if check_field.field_type == "field_group"
      end
      if is_multistep_form && field_group_size < 2
        errors.add(:base, "You must select at least 2 field groups for a Multi-step form")
      end
    end

    def ordered_fields
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
