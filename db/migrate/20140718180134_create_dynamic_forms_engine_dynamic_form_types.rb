class CreateDynamicFormsEngineDynamicFormTypes < ActiveRecord::Migration
  def change
    create_table :dynamic_forms_engine_dynamic_form_types do |t|
      t.string :name
      t.text :description
      t.string :uuid

      t.timestamps
    end
  end
end
