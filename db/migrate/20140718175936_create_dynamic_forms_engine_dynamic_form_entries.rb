class CreateDynamicFormsEngineDynamicFormEntries < ActiveRecord::Migration
  def change
    create_table :dynamic_forms_engine_dynamic_form_entries do |t|
      t.integer :dynamic_form_type_id
      t.text :properties
      t.string :uuid

      t.timestamps
    end
  end
end
