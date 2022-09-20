Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'

  get '/about', to: 'pages#about'
  get '/meal-prep', to: 'pages#meal_prep'
  get '/parties', to: 'pages#parties'
  get '/calendar', to: 'pages#calendar'

  get '/contact', to: 'contact#new'
  post '/contact', to: 'contact#create'
  get '/contact-success', to: 'contact#success'

  get '/menus/:slug', to: 'client_menu_submissions#new', as: 'menu_slug'
  get '/menus/:slug/success', to: 'client_menus#success', as: 'menu_slug_success'

  resources :client_menu_submissions, only: [:create]
  resources :meals, only: [:index, :show]

  namespace :admin do
    get '/pages', to: 'pages#index'
    get '/pages/:slug', to: 'pages#edit', as: :page
    patch '/pages/:slug', to: 'pages#update', as: :update_page

    get '/calendar', to: 'calendar#index'
    patch '/calendar', to: 'calendar#update', as: :update_calendar

    resources :clients
    resources :meals

    resources :client_menus, only: [:index, :show] do
      get '/categories', action: :categories
      get '/menu_items', action: :menu_items
      get '/results', action: :results
      get '/send_to_client', action: :send_to_client
    end

    root to: redirect('/users/sign_in')
  end

  namespace :api do
    get '/events', to: 'events#index'
    post '/events', to: 'events#create'
    post '/categories/weights', to: 'categories#update_weights'
    post '/menus/weights', to: 'menus#update_weights'

    resources :client_menus, only: [:index, :create, :show, :update] do
      get '/submission', action: 'submission'
      post '/duplicate', action: 'duplicate'
    end

    resources :client_menu_submissions, only: [:create]

    resources :client_menu_categories do
      collection do
        post '/weights', action: :update_weights
      end
    end

    resources :client_menu_items do
      collection do
        post '/weights', action: :update_weights
      end
    end
  end
end
