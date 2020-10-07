Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'

  get '/about', to: 'pages#about'
  get '/menus', to: 'pages#menus'
  get '/meal-prep', to: 'pages#meal_prep'
  get '/parties', to: 'pages#parties'
  get '/calendar', to: 'pages#calendar'
  get '/pricing', to: 'pages#pricing'

  get '/contact', to: 'contact#new'
  post '/contact', to: 'contact#create'
  get '/contact-success', to: 'contact#success'

  namespace :admin do
    get '/pages', to: 'pages#index'
    get '/pages/:slug', to: 'pages#edit', as: :page
    patch '/pages/:slug', to: 'pages#update', as: :update_page

    get '/calendar', to: 'calendar#index'
    patch '/calendar', to: 'calendar#update', as: :update_calendar

    root to: redirect('/users/sign_in')
  end

  namespace :api do
    get '/events', to: 'events#index'
    post '/events', to: 'events#create'
  end
end
