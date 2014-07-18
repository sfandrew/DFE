class AddUserIdToDynamicFormTypes < ActiveRecord::Migration
  def change
    add_column :dynamic_forms_engine_dynamic_form_types, :user_id, :integer
  end
end
