class AddApplicationPdfToDynamicFormsEngineDynamicFormEntries < ActiveRecord::Migration
  def change
  	add_column :dynamic_forms_engine_dynamic_form_entries, :application_pdf, :string unless column_exists? :dynamic_forms_engine_dynamic_form_entries, :application_pdf
  end
end
