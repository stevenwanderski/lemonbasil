Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'

  get '/about', to: 'pages#about'
  get '/meal-prep', to: 'pages#meal_prep'
  get '/parties', to: 'pages#parties'

  get '/contact', to: 'contact#new'
  post '/contact', to: 'contact#create'
  get '/contact-success', to: 'contact#success'

  get '/job-apply', to: 'jobs#new'
  post '/job-apply', to: 'jobs#create'
  get '/job-apply-success', to: 'jobs#success'

  get '/waitlist', to: 'waitlist#new'
  post '/waitlist', to: 'waitlist#create'
  get '/waitlist-success', to: 'waitlist#success'

  get '/menus/:slug', to: 'client_menu_submissions#new', as: 'menu_slug'
  get '/menus/:slug/success', to: 'client_menu_submissions#success', as: 'menu_slug_success'

  post '/menus/:slug/staples', to: 'client_menu_submissions#save_staples', as: 'save_staples'
  get '/menus/:slug/staples_success', to: 'client_menu_submissions#staples_success', as: 'staples_success'

  get '/instructions/', to: redirect('/instructions/beth'), as: 'instructions_old'
  get '/instructions/:slug', to: 'instructions#index', as: 'instructions'
  get '/instructions/:slug/:id', to: 'instructions#show', as: 'instruction'

  get '/meals', to: redirect('/instructions')
  get '/meals/:id', to: redirect('/instructions/%{id}')

  resources :client_menu_submissions, only: [:create] do
    collection do
      post '/update_totals', action: :update_totals
    end
  end

  namespace :admin do
    get '/pages', to: 'pages#index'
    get '/pages/:slug', to: 'pages#edit', as: :page
    patch '/pages/:slug', to: 'pages#update', as: :update_page

    resources :clients
    resources :instructions
    resources :users do
      member do
        get '/switch_user', action: :switch_user, as: :switch_user
      end
    end

    resources :client_menus do
      collection do
        get '/monthly', action: :monthly
        get '/monthly/:year/:month', action: :monthly_show, as: :monthly_show
      end
      get '/categories', action: :categories
      get '/menu_items', action: :menu_items
      get '/staples', action: :staples
      get '/staple_categories', action: :staple_categories
      get '/results', action: :results
      get '/send_to_client', action: :send_to_client
      post '/update_category_weights', action: :update_category_weights
      post '/update_menu_item_weights', action: :update_menu_item_weights
      post '/update_staple_weights', action: :update_staple_weights
      post '/update_staple_category_weights', action: :update_staple_category_weights

      resources :categories, controller: 'client_menus/categories'
      resources :duplicates, only: [:new, :create], controller: 'client_menus/duplicates'
      resources :shares, only: [:new, :update], controller: 'client_menus/shares'
      resources :items, only: [:new, :create, :edit, :update, :destroy], controller: 'client_menus/items'
      resources :staples, only: [:new, :create, :edit, :update, :destroy], controller: 'client_menus/staples'
      resources :staple_categories, only: [:new, :create, :edit, :update, :destroy], controller: 'client_menus/staple_categories'
    end

    get '/account', to: 'account#show', as: 'account'
    put '/account', to: 'account#update', as: 'account_update'

    root to: redirect('/users/sign_in')
  end

  namespace :api do
    get '/events', to: 'events#index'
    post '/events', to: 'events#create'
  end
end
