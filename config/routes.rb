Rails.application.routes.draw do
  root to: 'pages#home'

  get '/about', to: 'pages#about'
  get '/menus', to: 'pages#menus'
  get '/meal-prep', to: 'pages#meal_prep'
  get '/parties', to: 'pages#parties'

  get '/contact', to: 'contact#new'
  post '/contact', to: 'contact#create'
  get '/contact-success', to: 'contact#success'
end
