require 'sidekiq/web'

Rails.application.routes.draw do
  # Sidekiq Web UI (should be protected in production)
  mount Sidekiq::Web => '/sidekiq'

  # Devise routes outside namespace for proper URL generation
  devise_for :users,
             path: 'api/v1/auth',
             path_names: {
               sign_in: 'login',
               sign_out: 'logout',
               registration: 'signup'
             },
             controllers: {
               sessions: 'api/v1/sessions',
               registrations: 'api/v1/registrations'
             }

  namespace :api do
    namespace :v1 do
      # Get current user
      get 'auth/me', to: 'current_user#show'

      # Management Resources
      resources :users, only: %i[index show create update destroy]
      resources :items, only: %i[index show create update destroy]

      # Reports
      get 'reports/dashboard', to: 'reports#dashboard'
      get 'reports/metrics', to: 'reports#metrics'
      get 'reports/trends', to: 'reports#trends'
    end
  end

  # Health checks
  get '/health', to: proc { [200, {}, ['OK']] }
  get '/up', to: proc { [200, { 'Content-Type' => 'text/plain' }, ['OK']] }
end
