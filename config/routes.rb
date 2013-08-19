Office::Application.routes.draw do

  match "/employees/show_monthly_report" => "employees#show_monthly_report"
  match "/employees/generate_time_records" => "employees#generate_time_records"
  match "/employees/import_from_machine" => "employees#import_from_machine"
  match "/employees/bulk_add_time_records" => "time_records#bulk_add"
  match "/employees/bulk_create_time_records" => "time_records#bulk_create"
  match "/employees/bulk_calculator" => "time_records#bulk_calculator"

  resources :employees
  resources :truckings
  resources :customers
  resources :time_records
  resources :ta_record_infos

  match "/employees/:employee_id/time_records/calculator" => "time_records#calculator"
  match "/employees/:employee_id/time_records/:id/calculator" => "time_records#calculator"

  resources :rsvps

  match "/contact_us" => "rsvps#contact_us"
  match "/wedding_rsvp" => "rsvps#rsvp"

  resources :employees do
    resources :time_records
    resources :deductions
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
