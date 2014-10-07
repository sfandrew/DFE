class AddIncludedInReportToDynamicFormsEngineDynamicFormEntries < ActiveRecord::Migration
  def change
    add_column :dynamic_forms_engine_dynamic_form_fields, :included_in_report, :boolean
  end
end
