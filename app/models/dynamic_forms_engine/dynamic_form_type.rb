module DynamicFormsEngine
  class DynamicFormType < ActiveRecord::Base
  	has_many :fields, class_name: "DynamicFormField",  :dependent => :destroy
    has_many :entries, class_name: "DynamicFormEntry"

    validates :name, :description, :fields, presence: true
    validates :form_type, presence: true, :inclusion => { :in => %w(Default-form Multi-step), 
                                                      :message => "%{value} is not a valid choice" }

    accepts_nested_attributes_for :fields, allow_destroy: true

    before_create :add_other_option
    before_update :other_option_validate

    def add_other_option
      self.fields.each do |other_field|
        if other_field.field_type == "options_select_with_other"
          other_field.content_meta << ",Other"
          puts "\n\n\n This is getting called! \n\n\n"
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
    
  end
end
