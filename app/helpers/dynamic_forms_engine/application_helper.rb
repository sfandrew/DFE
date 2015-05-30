module DynamicFormsEngine
  module ApplicationHelper

    def sign_form_field_tag(name, data)
      return hidden_field_tag(name,"", :hidden => true)+content_tag(:div,"",:id => "#{name}_sig")+
		      content_tag(:script,("jQuery(document).ready(function() {
		      		    var x = jQuery('##{name}_sig');
		      		    x.jSignature();
		      		    " + 
		      		    (!data.blank? && !(data == "image/jsignature;base30,") ? ("x.jSignature('setData', '#{data}', 'base30');
		      		    	" ) : "") + 
		      		    "jQuery('##{name}').val(x.jSignature('getData', 'base30'));
		      		    x.change(function(){
		      		      jQuery('##{name}').val(x.jSignature('getData', 'base30'));
		      		    });
		      		    
		      		  });").html_safe)
    end

  	
  	# Adds n-th number of contacts
	def link_to_add_fields(name, f, association)
		
		# new_object = f.object.send(association).klass.new
		# id = new_object.object_id
		
		# fields = f.fields_for(association, new_object, child_index: id) do |builder|
		# 	render(association.to_s.singularize + "_fields", f: builder)
		# end

		link_to(name, '#', class: "add_fields btn btn-info") 
			#data: {id: id, fields: fields.gsub("\n", "")})
	
	end
	
	# Adds n-th number of fields for dynamic form builder
	def link_to_add_many_fields(name, f, association)
		new_object = f.object.send(association).klass.new
		id = new_object.object_id
		
		fields = f.fields_for(association, new_object, child_index: id) do |builder|
			render(association.to_s.singularize + "_fields", f: builder)
		end
		link_to(name, '#', class: "add_many_fields btn btn-info", data: {id: id, fields: fields.gsub("\n", "")})
	end

	# Creates display html for any object with address fields
	def display_address(obj)

		if !obj.blank? && obj.building_address
			ret = ""
			ret << strip_tags(obj.building_address)
			ret << "<br />"
			if !obj.building_address2.blank?
			 	ret << strip_tags(obj.building_address2)
			 	ret << "<br />"
			end
			ret << strip_tags("#{obj.building_city}, #{obj.building_state}  #{obj.building_zip}")

			return ret.html_safe
		else
			return "No Address"
		end
	end
	
	def us_states
	    [
	      ['-- Select --',''],
	      ['Alabama', 'AL'],
	      ['Alaska', 'AK'],
	      ['Arizona', 'AZ'],
	      ['Arkansas', 'AR'],
	      ['California', 'CA'],
	      ['Colorado', 'CO'],
	      ['Connecticut', 'CT'],
	      ['Delaware', 'DE'],
	      ['District of Columbia', 'DC'],
	      ['Florida', 'FL'],
	      ['Georgia', 'GA'],
	      ['Hawaii', 'HI'],
	      ['Idaho', 'ID'],
	      ['Illinois', 'IL'],
	      ['Indiana', 'IN'],
	      ['Iowa', 'IA'],
	      ['Kansas', 'KS'],
	      ['Kentucky', 'KY'],
	      ['Louisiana', 'LA'],
	      ['Maine', 'ME'],
	      ['Maryland', 'MD'],
	      ['Massachusetts', 'MA'],
	      ['Michigan', 'MI'],
	      ['Minnesota', 'MN'],
	      ['Mississippi', 'MS'],
	      ['Missouri', 'MO'],
	      ['Montana', 'MT'],
	      ['Nebraska', 'NE'],
	      ['Nevada', 'NV'],
	      ['New Hampshire', 'NH'],
	      ['New Jersey', 'NJ'],
	      ['New Mexico', 'NM'],
	      ['New York', 'NY'],
	      ['North Carolina', 'NC'],
	      ['North Dakota', 'ND'],
	      ['Ohio', 'OH'],
	      ['Oklahoma', 'OK'],
	      ['Oregon', 'OR'],
	      ['Pennsylvania', 'PA'],
	      ['Puerto Rico', 'PR'],
	      ['Rhode Island', 'RI'],
	      ['South Carolina', 'SC'],
	      ['South Dakota', 'SD'],
	      ['Tennessee', 'TN'],
	      ['Texas', 'TX'],
	      ['Utah', 'UT'],
	      ['Vermont', 'VT'],
	      ['Virginia', 'VA'],
	      ['Washington', 'WA'],
	      ['West Virginia', 'WV'],
	      ['Wisconsin', 'WI'],
	      ['Wyoming', 'WY']
	    ]
	end
  end
end
