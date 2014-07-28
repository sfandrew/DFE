module DynamicFormsEngine
  class DynamicFormType < ActiveRecord::Base
  	has_many :fields, class_name: "DynamicFormField",  :dependent => :destroy
    has_many :entries, class_name: "DynamicFormEntry"

    validates :name, :description, :fields, presence: true

    accepts_nested_attributes_for :fields, allow_destroy: true

    before_create :add_other_option

    def add_other_option
      self.fields.each do |other_field|
        if other_field.field_type == "options_select_with_other"
          other_field.content_meta << ",Other"
          puts "\n\n\n This is getting called! \n\n\n"
        end
      end
    end



  end
end
