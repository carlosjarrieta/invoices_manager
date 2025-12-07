Rails.application.routes.draw do
  # API V1 Routes
  namespace :api do
    namespace :v1 do
      # Auth Endpoint
      post 'auth/login', to: 'authentication#login'

      # Microservice Endpoint: Create Invoice
      resources :invoices, only: %i[create show]

      # Microservice Endpoint: Clients
      get 'clients/search_by_nit', to: 'clients#search_by_nit'
      resources :clients, except: :destroy

      # Audit Logs
      get 'audit_logs/by_entity', to: 'audit_logs#by_entity'
      resources :audit_logs, only: %i[index show]
    end
  end
end
