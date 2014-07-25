module DynamicFormsEngine
  class DynamicFormType < ActiveRecord::Base
  	has_many :fields, class_name: "DynamicFormField", :order => 'field_order ASC', :dependent => :destroy
  	has_many :entries, class_name: "DynamicFormEntry"

  	validates :name, :description, :fields, presence: true

  	accepts_nested_attributes_for :fields, allow_destroy: true

  	validate :validate_contacts


  	# contacts can only exist one time for each form type
    def validate_contacts
      signature = 0
      contacts = 0
      if self.fields
        self.fields.each do |contact|
          if contact.field_type == "contacts"
            contacts += 1
          elsif  contact.field_type == "signature"
              signature += 1
          end
        end
      end
      if contacts > 1 
        errors[:base] << "You can only choose one contact field per Form!"
      elsif signature > 1
        errors[:base] << "You can only chose one signature field per Form!"
      elsif contacts > 1 && signature > 1
        errors[:base] << "You can only chose one contact and one signature field per Form!"
      end
    end
  end
end
