Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#dashboard"

  get "login", to: "pages#login"
  get "categories", to: "pages#categories"
  get "courses", to: "pages#courses"
  get "courses/:id", to: "pages#course_detail", as: :course_detail
  get "my-courses", to: "pages#my_courses"
  get "lectures/:id", to: "pages#lecture_player", as: :lecture_player
  get "progress", to: "pages#progress"
  get "api-lab", to: "pages#api_lab", as: :api_lab
  get "membership", to: "memberships#show"
  get "membership/plans", to: "memberships#plans", as: :membership_plans
  get "membership/checkout", to: "memberships#checkout", as: :membership_checkout
  get "membership/account", to: "memberships#account", as: :membership_account
  post "membership/subscribe", to: "memberships#subscribe", as: :membership_subscribe
  patch "membership/cancel", to: "memberships#cancel", as: :membership_cancel
  get "rehearsals", to: "rehearsals#index", as: :rehearsals
  get "rehearsals/:id", to: "rehearsals#show", as: :rehearsal_detail
  post "rehearsals", to: "rehearsals#create", as: :rehearsal_submissions
  get "coaching/products", to: "coaching#products", as: :coaching_products
  post "coaching/purchases", to: "coaching#purchase", as: :coaching_purchase
  get "coaching/requests", to: "coaching#requests", as: :coaching_requests
  get "coaching/requests/:id", to: "coaching#show_request", as: :coaching_request_detail
  get "coaching/request", to: "coaching#new_request", as: :new_coaching_request
  post "coaching/request", to: "coaching#create_request", as: :coaching_request

  namespace :admin do
    root "dashboard#show"
    get "dashboard", to: "dashboard#show"
    get "access-denied", to: "dashboard#access_denied", as: :access_denied
    get "setup", to: "setup#new"
    post "setup", to: "setup#create"
    resources :users, only: [:index, :update, :destroy]
    resources :courses, only: [:index, :destroy]
    resources :categories, only: [:index, :create, :update, :destroy]
    get "settlements/membership", to: "settlements#membership", as: :settlement_membership
    get "settlements/coaching", to: "settlements#coaching", as: :settlement_coaching
    get "settlements/instructors", to: "settlements#instructors", as: :settlement_instructors
  end

  namespace :instructor do
    root "courses#index"
    get "access-denied", to: "courses#access_denied", as: :access_denied
    get "coaching/queue", to: "coaching#index", as: :coaching_queue
    get "coaching/requests/:id", to: "coaching#show", as: :coaching_request
    patch "coaching/requests/:id", to: "coaching#update"
    get "settlements", to: "settlements#index", as: :settlements
    get "settlements/month", to: "settlements#month", as: :settlement_month
    resources :courses, only: [:index, :new, :create, :edit, :update, :destroy] do
      resources :lectures, only: [:new, :create, :edit, :update, :destroy], module: :courses
    end
  end

  namespace :api do
    scope module: :v1 do
      post "auth/signup", to: "auth#signup"
      post "auth/login", to: "auth#login"
      post "auth/refresh", to: "auth#refresh"
      post "auth/logout", to: "auth#logout"

      resources :categories, only: [:index, :show]
      resources :courses, only: [:index, :show] do
        resources :lectures, only: [:index], controller: "lectures"
      end

      resources :lectures, only: [:show] do
        post :progress, on: :member
      end

      get "users/me/courses", to: "users#me_courses"
      get "users/me/progress", to: "users#me_progress"
    end

    namespace :v1 do
      post "auth/signup", to: "auth#signup"
      post "auth/login", to: "auth#login"
      post "auth/refresh", to: "auth#refresh"
      post "auth/logout", to: "auth#logout"

      resources :categories, only: [:index, :show]
      resources :courses, only: [:index, :show] do
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
