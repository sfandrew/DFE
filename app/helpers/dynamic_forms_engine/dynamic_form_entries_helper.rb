module DynamicFormsEngine
  module DynamicFormEntriesHelper
  	

    # Loops over fields for this form and renders them
    def render_fields(dynamic_form_entry, builder)

      return_html = ""
      cols = 0
      form_group_exists = false
      dynamic_form_type = dynamic_form_entry.dynamic_form_type

      # raise keys: dynamic_form_entry.errors.keys, ids: dynamic_form_entry.ordered_fields.map(&:id)

      # For each field ...
      dynamic_form_type.ordered_fields.each_with_index do |field, i|

        next_field = dynamic_form_type.ordered_fields[i+1]

        # FIELDSET
        # if one field_group already exists, end one fieldset for the start of the next one
        if field.field_type == "field_group"
          if form_group_exists
            return_html += "</div>"         # Close row
            return_html += "<div class='clear spacer'></div>"   # Add spacer before fieldset close
            return_html += "</fieldset>"    # Close field set
            cols = 0
          end
          return_html += "<fieldset><legend>#{field.name.humanize}</legend>"
          form_group_exists = true
        end

        # ROWS
        if !field.field_width.blank? && field.field_width.to_i > 0
          return_html += '<div class="row dfe-fields-row">' if cols == 0  # New row
          # Update cols with field
          cols += field.field_width.to_i 
        end

        if (cols > 12) && (field.field_type != "field_group")
          return_html += "</div>"                             # Close row
          return_html += "<div class='clear spacer'></div>"   # Add spacer
          return_html += "<div class='row dfe-fields-row'>"   # Open new row
          cols = field.field_width.to_i
        end

        errors = dynamic_form_entry.errors.full_messages_for(field.name.to_sym)
        return_html += render_field_with_value(field,errors,builder,dynamic_form_entry)

      end

      return_html += "</div>"           # Last row

      # FIELDSET - last closed
      if form_group_exists
        return_html += "</fieldset>"    # Last fieldset
      end

      # Add space between last field and submit button
      return_html += "<div class='clear spacer'></div>" 

      return_html.html_safe

    end

    # Handles logic and rendering of individual field when creating dynamic form entries
    def render_field_with_value(field, errors, builder, dynamic_form_entry)
      field_value = nil
        if !dynamic_form_entry.properties[0].nil?
          dynamic_form_entry.properties.each do |key,value|
            if field.id == value[:id].to_i
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
