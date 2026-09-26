Rails.application.routes.draw do

  resource :session
  resources :passwords, param: :token
  get "signup", to: "user_registrations#new", as: :new_user
  post "signup", to: "user_registrations#create", as: :users

  get "up" => "rails/health#show", as: :rails_health_check

  namespace :admin do
    resources :clubs do
      resources :schedules, only: %i[new create]
      resources :courts
      resources :reservations, only: %i[new create show] do
        resources :payments, only: %i[new create]
      end
    end
  end

  namespace :api do
    namespace :v1 do

      post 'login', to: 'sessions#create'
      delete 'logout', to: 'sessions#destroy'

      resources :clubs, only: %i[index show] do
        resources :courts, only: %i[index show]
        resources :reservations, only: %i[index create show]
      end

      resources :users, only: %i[create show]
    end
  end

  root "admin/clubs#index"
end