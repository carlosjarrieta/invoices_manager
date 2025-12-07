Rails.application.routes.draw do
  # API V1 Routes
  namespace :api do
    namespace :v1 do
      # Auth Endpoint
      post 'auth/login', to: 'authentication#login'

      # Microservice Endpoint: Create Invoice
      post 'invoices', to: 'invoices#create'

      # Microservice Endpoint: Clients
      get 'clients/search_by_nit', to: 'clients#search_by_nit'
      resources :clients, except: :destroy
    end
  end
end
