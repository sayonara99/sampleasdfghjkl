Rails.application.routes.draw do

  root 'pages#home'
  get '/about', to: 'pages#about'
  get '/signup', to: 'users#signup'
  resources :users

end
