class AddUserIdToDynamicFormEntries < ActiveRecord::Migration
  def change
    add_column :dynamic_forms_engine_dynamic_form_entries, :user_id, :integer
  end
end
