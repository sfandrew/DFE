json.array!(@dynamic_form_types) do |dynamic_form_type|
  json.extract! dynamic_form_type, :name, :user_id, :description
  json.url dynamic_form_type_url(dynamic_form_type, format: :json)
end
