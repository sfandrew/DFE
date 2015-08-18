class AddLastSectionSavedToDynamicFormsEngineDynamicFormEntries < ActiveRecord::Migration
  def change
  	add_column :dynamic_forms_engine_dynamic_form_entries, :last_section_saved, :string unless column_exists? :dynamic_forms_engine_dynamic_form_entries, :last_section_saved
  end
end
