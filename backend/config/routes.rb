Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#dashboard"

  get "signup", to: "pages#signup"
  get "login", to: "pages#login"
  get "categories", to: "pages#categories"
  get "courses", to: "pages#courses"
  get "courses/demo", to: "pages#course_detail", as: :course_detail
  get "my-courses", to: "pages#my_courses"
  get "lectures/demo", to: "pages#lecture_player", as: :lecture_player
  get "progress", to: "pages#progress"

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
