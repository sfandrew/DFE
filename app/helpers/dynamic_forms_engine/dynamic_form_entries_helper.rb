module DynamicFormsEngine
  module DynamicFormEntriesHelper
  	

    # Loops over fields for this form and renders them
    def render_fields(dynamic_form_entry, builder)
      return_html = ""
      form_group_exists = false

      dynamic_form_entry.dynamic_form_type.ordered_fields.each do |field|
  
        # if one field_group already exists, end one fieldset for the start of the next one
        if field.field_type == "field_group"
          if form_group_exists
            return_html += "</fieldset>"
          end
          form_group_exists = true
          return_html += "<fieldset><legend>#{field.name.humanize}</legend>"
        end
        
        return_html += render_individual_field(field, builder)
      end

      return_html += "</fieldset>" if form_group_exists #final closing fieldset tag
      
      return_html.html_safe
    end

    # Handles logic and rendering of individual field when creating dynamic form entries
  	def render_individual_field(field, builder)
  		render :partial => "dynamic_forms_engine/dynamic_form_entries/fields/#{field.field_type}", locals: {field: field, f: builder}
  	end


  end
end
