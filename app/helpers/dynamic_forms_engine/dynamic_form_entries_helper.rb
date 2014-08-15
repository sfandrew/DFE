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
          return_html += ("<fieldset id='step_#{i}' class='field-group'><legend>#{field.name.humanize}</legend>")
        end
        
        errors = dynamic_form_entry.errors.full_messages_for(field.name.to_sym)
        return_html += render_individual_field(field, errors, builder)
      end

      return_html += "</fieldset>" if form_group_exists #final closing fieldset tag
      
      return_html.html_safe
    end

    # Handles logic and rendering of individual field when creating dynamic form entries
  	def render_individual_field(field, errors, builder)
  		render partial: "dynamic_forms_engine/dynamic_form_entries/fields/#{field.field_type}", 
             locals: {field: field, f: builder, errors: errors}
  	end


  end
end
