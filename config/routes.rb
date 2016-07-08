DynamicFormsEngine::Engine.routes.draw do
	resources :dynamic_form_entries  do
    collection do
      get 'all_entries'
    end
  end
  
	match 'dynamic_form_entries/new/:dynamic_form_type_id', 
    to: 'dynamic_form_entries#new', 
    via: [:get, :post],
    as: "new_form_entry"

  match 'form_entries/:dynamic_form_type_id', 
    to: 'dynamic_form_entries#form_entries', 
    via: [:get],
    as: "form_entries"

  resources :dynamic_form_types

  namespace :api do
    get 'dynamic_forms_engine/dynamic_form_entries/get_many' => 'dynamic_form_entries#get_many'
  end
  
  root 'dynamic_form_types#index'
end
