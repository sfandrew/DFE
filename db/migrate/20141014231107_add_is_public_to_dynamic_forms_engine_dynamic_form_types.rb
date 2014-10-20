class AddIsPublicToDynamicFormsEngineDynamicFormTypes < ActiveRecord::Migration
  def change
  	 add_column :dynamic_forms_engine_dynamic_form_types, :is_public, :boolean unless column_exists? :dynamic_forms_engine_dynamic_form_types, :is_public
  end
end
