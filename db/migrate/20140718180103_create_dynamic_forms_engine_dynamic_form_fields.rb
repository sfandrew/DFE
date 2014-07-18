class CreateDynamicFormsEngineDynamicFormFields < ActiveRecord::Migration
  def change
    create_table :dynamic_forms_engine_dynamic_form_fields do |t|
      t.integer :dynamic_form_type_id
      t.integer :field_order
      t.string :name
      t.string :field_type
      t.boolean :required
      t.text :content_meta

      t.timestamps
    end
  end
end
