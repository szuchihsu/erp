Rails.application.routes.draw do
  devise_for :users, skip: [ :registrations ]
  root "dashboard#index"

  get "dashboard", to: "dashboard#index"

  # User management (admin only)
  resources :users

  # Production system
  resources :production_orders do
    member do
      patch :start
      patch :complete
    end
    resources :work_orders, only: [ :show, :edit, :update ] do
      member do
        patch :start_work
        patch :complete_work
      end
    end
  end

  resources :employees
  resources :customers
  resources :products do
    resources :inventory_transactions
    resources :inventory_adjustments
    resources :bill_of_materials do
      member do
        patch :activate
        post :copy
      end
    end
  end

  resources :sales_orders do
    member do
      patch :fulfill
      patch :cancel
    end
    resources :sales_order_items, except: [ :index, :show ]
  end

  # Inventory routes
  get "inventory", to: "inventory#index"
  get "inventory/transactions", to: "inventory#transactions"

  # Product inventory management
  get "inventory/product/:product_id/adjust", to: "inventory#adjust_stock", as: "adjust_inventory"
  post "inventory/product/:product_id/adjust", to: "inventory#create_adjustment"
  get "inventory/product/:product_id/restock", to: "inventory#restock", as: "restock_inventory"
  post "inventory/product/:product_id/restock", to: "inventory#create_restock"

  # Material inventory management
  get "inventory/material/:material_id/adjust", to: "inventory#adjust_stock", as: "adjust_material_inventory"
  post "inventory/material/:material_id/adjust", to: "inventory#create_adjustment"
  get "inventory/material/:material_id/restock", to: "inventory#restock", as: "restock_material_inventory"
  post "inventory/material/:material_id/restock", to: "inventory#create_restock"

  resources :design_requests do
    member do
      patch :approve
      patch :reject
      patch :assign
    end

    resources :design_images, only: [ :create, :destroy ]
  end

  # Add design requests to sales orders
  resources :sales_orders do
    resources :design_requests, only: [ :new, :create ]
  end

  resources :materials do
    resources :inventory_transactions
    resources :inventory_adjustments
    member do
      patch :adjust_stock
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
