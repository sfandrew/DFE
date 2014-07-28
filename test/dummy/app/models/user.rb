class User < ActiveRecord::Base
  has_many :dynamic_form_entries, class_name: "DynamicFormsEngine::DynamicFormEntry"


  def email
  	"fakeemail@dummyuser.fake"
  end
end
