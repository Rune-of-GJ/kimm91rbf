Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"

  namespace :api do
    scope module: :v1 do
      post "auth/signup", to: "auth#signup"
      post "auth/login", to: "auth#login"
      post "auth/refresh", to: "auth#refresh"
      post "auth/logout", to: "auth#logout"

      resources :categories, only: [:index, :show]
      resources :courses, only: [:index, :show] do
        post :enroll, on: :member
        resources :lectures, only: [:index], controller: "lectures"
      end

      resources :lectures, only: [:show] do
        post :progress, on: :member
      end

      get "users/me/courses", to: "users#me_courses"
      get "users/me/progress", to: "users#me_progress"
    end
  end
end
