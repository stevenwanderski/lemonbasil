Rails.application.routes.draw do
  root to: 'pages#home'

  get '/how-it-works', to: 'pages#how_it_works'
  get '/about', to: 'pages#about'
  get '/menus', to: 'pages#menus'
  get '/contact', to: 'pages#contact'
end
