module DynamicFormsEngine
  module DynamicFormEntriesHelper
  	

    # Loops over fields for this form and renders them
    def render_fields(dynamic_form_entry, builder)
      return_html = ""
      form_group_exists = false
      # raise keys: dynamic_form_entry.errors.keys, ids: dynamic_form_entry.ordered_fields.map(&:id)
      dynamic_form_entry.dynamic_form_type.ordered_fields.each_with_index do |field,i|
  
        # if one field_group already exists, end one fieldset for the start of the next one
        if field.field_type == "field_group"
          if form_group_exists
            return_html += "</fieldset>"
          end
          form_group_exists = true
          return_html += ("<fieldset id='step_#{field.id}' class='field-group'><legend>#{field.name.humanize}</legend>")
        end
        errors = dynamic_form_entry.errors.full_messages_for(field.name.to_sym)
        return_html += render_field_with_value(field,errors,builder,dynamic_form_entry)
      end
      return_html += "</fieldset>" if form_group_exists #final closing fieldset tag
      return_html.html_safe
    end

    # Handles logic and rendering of individual field when creating dynamic form entries
    def render_field_with_value(field, errors, builder, dynamic_form_entry)
      field_value = nil
        if !dynamic_form_entry.properties[0].nil?
          dynamic_form_entry.properties.each do |key,value|
            if field.name == value[:name] && field.field_type == value[:type]
              field_value = value[:value]
              break
            end
          end
        end
      render partial: "dynamic_forms_engine/dynamic_form_entries/fields/#{field.field_type}", 
             locals: {field: field, f: builder, errors: errors, field_value: field_value}
    end


  end
end
