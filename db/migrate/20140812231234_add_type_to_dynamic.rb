class AddTypeToDynamic < ActiveRecord::Migration
  def change
    add_column :dynamic_forms_engine_dynamic_form_types, :type, :string
  end
end
