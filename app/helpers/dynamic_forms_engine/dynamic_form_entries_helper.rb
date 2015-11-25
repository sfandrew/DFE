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
            return_html += "</div></fieldset>"    # Close field set
            cols = 0
          end
          return_html += "<fieldset id='step_#{field.id}' data-field-group-name='#{field.name}' class='field-group'><legend class='legend-title'>#{field.name}</legend><div class='input-box'>"
          form_group_exists = true
        
        elsif field.field_type != "field_group"
          # ROWS
          if field.field_width != "false" && field.field_width.to_i > 0 
            return_html += '<div class="row dfe-fields-row">' if cols == 0  # New row
            # Update cols with field
            cols += field.field_width.to_i 
          end
          # close row and open new row
          if cols > 12
            return_html += "</div>"                             # Close row
            return_html += "<div class='clear spacer'></div>"   # Add spacer
            return_html += "<div class='row dfe-fields-row'>"   # Open new row
            cols = field.field_width.to_i
          end
        end

        errors = dynamic_form_entry.errors.full_messages_for(field.name.to_sym) if field.required?
        #errors are being added based on name, fields with same name will see errors 
        return_html += render_field_with_value(field,errors,builder,dynamic_form_entry)

      end

      return_html += "</div>"           # Last row

      # Add space between last row and fieldset end
      return_html += "<div class='clear spacer'></div>" 

      # FIELDSET - last closed
      return_html += "</div></fieldset>" if form_group_exists 
  
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

    # builds date select
    # needs more refactoring when multiple date selects
    def date_select(f,field_id, field_value = nil)

      date_options = { "month_#{field_id}" => (1..12).map { |month| [Date::MONTHNAMES[month], month] }, 
                      "day_#{field_id}" => (1..31).to_a, 
                      "year_#{field_id}" => Time.now.year.downto(Time.now.year - 100).to_a }

      # if date exists, select it

      if !field_value.blank?
        date_object = Date.parse(field_value)

        date_values = [ date_object.mon, date_object.day, date_object.year]
      else
        date_values = ''
      end
      # builds the dropdowns
      date_dropdown = ""
      date_options.each_with_index do | (key, date), index |

        selected_value = params[key] || date_values[index]

        date_dropdown += select_tag(key, options_for_select(date, selected_value), { :class => 'form-control date-select', :style => 'width:auto; display:inline;'})
      end
      # selects date on failed form validation
      if params[date_options.keys[0]].present? && params[date_options.keys[1]].present? && params[date_options.keys[2]].present?
        field_date_object = Date.new(params[date_options.keys[2]].to_i , params[date_options.keys[0]].to_i, params[date_options.keys[1]].to_i)
        date_dropdown += f.hidden_field field_id, value: field_date_object, :class => "field-value form-control"
      else
        date_dropdown += f.hidden_field field_id, value: field_value, :class => "field-value form-control"
      end

      return date_dropdown.html_safe

    end



  end
end
