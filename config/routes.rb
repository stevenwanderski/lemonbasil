Rails.application.routes.draw do
  devise_for :users
  root to: 'pages#home'

  get '/about', to: 'pages#about'
  get '/menus', to: 'pages#menus'
  get '/meal-prep', to: 'pages#meal_prep'
  get '/parties', to: 'pages#parties'

  get '/contact', to: 'contact#new'
  post '/contact', to: 'contact#create'
  get '/contact-success', to: 'contact#success'

  namespace :admin do
    get '/pages', to: 'pages#index'
    get '/pages/:slug', to: 'pages#edit', as: :page
    patch '/pages/:slug', to: 'pages#update', as: :update_page

    root to: redirect('/admin/pages')
  end
end
