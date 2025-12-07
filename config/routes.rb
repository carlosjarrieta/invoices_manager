Rails.application.routes.draw do
  # API V1 Routes
  namespace :api do
    namespace :v1 do
      # Microservice Endpoint: Create Invoice
      post 'invoices', to: 'invoices#create'

      # Microservice Endpoint: Clients
      resources :clients, except: :destroy
    end
  end
end
