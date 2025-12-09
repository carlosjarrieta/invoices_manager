Rails.application.routes.draw do
  get 'up' => 'rails/health#show', as: :rails_health_check

  # API v1 Routes
  namespace :api do
    namespace :v1 do
      # Authentication endpoint
      post :authenticate, to: 'authentication#create'

      resources :clients, only: [:index, :create, :show] do
        collection do
          get :search_by_nit
        end
      end
    end
  end

end
