Rails.application.routes.draw do
  devise_for :users
  root "dashboard#index"

  get "dashboard", to: "dashboard#index"

  resources :employees
  resources :customers
  resources :products

  resources :sales_orders do
    resources :sales_order_items
  end

  # Inventory routes
  get "inventory", to: "inventory#index"
  get "inventory/transactions", to: "inventory#transactions"

  # Adjustment routes
  get "inventory/adjust/:product_id", to: "inventory#adjust_stock", as: "adjust_inventory"
  post "inventory/adjust/:product_id", to: "inventory#create_adjustment", as: "create_adjustment_inventory"

  # Restock routes
  get "inventory/restock/:product_id", to: "inventory#restock", as: "restock_inventory"
  post "inventory/restock/:product_id", to: "inventory#create_restock", as: "create_restock_inventory"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
