DynamicFormsEngine::Engine.routes.draw do
	resources :dynamic_form_entries 
	match 'dynamic_form_entries/new/:dynamic_form_type_id', 
    to: 'dynamic_form_entries#new', 
    via: [:get, :post],
    as: "new_form_entry"

    match 'form_entries/:dynamic_form_type_id', 
      to: 'dynamic_form_entries#form_entries', 
      via: [:get],
      as: "form_entries"

    resources :dynamic_form_types

    root 'dynamic_form_types#index'
end
