class AddInProgressToDynamicFormsEngineDynamicFormEntries < ActiveRecord::Migration
  def change
    add_column :dynamic_forms_engine_dynamic_form_entries, :in_progress, :boolean unless column_exists? :dynamic_forms_engine_dynamic_form_entries, :in_progress
  end
end
