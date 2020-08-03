Rails.application.routes.draw do
  root to: 'pages#home'

  get '/how-it-works', to: 'pages#how_it_works'
  get '/about', to: 'pages#about'
  get '/menus', to: 'pages#menus'

  get '/contact', to: 'contact#new'
  post '/contact', to: 'contact#create'
  get '/contact-success', to: 'contact#success'
end
