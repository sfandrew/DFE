class AddFormTypeToDynamicFormsEngineDynamicFormType < ActiveRecord::Migration
  def change
    add_column :dynamic_forms_engine_dynamic_form_types, :form_type, :string unless column_exists? :dynamic_forms_engine_dynamic_form_types, :form_type
  end
end
