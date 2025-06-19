Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :courses, only: [:create, :index]
    end
    namespace :v2 do
      resources :courses, only: [:create]
    end
  end
end
