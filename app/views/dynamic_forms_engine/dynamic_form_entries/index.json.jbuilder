json.array!(@dynamic_form_entries) do |dynamic_form_entry|
  json.extract! dynamic_form_entry, :dynamic_form_type_id, :properties
  json.url dynamic_form_entry_url(dynamic_form_entry, format: :json)
end
