Rails.application.routes.draw do

  root 'pages#home'
  get '/about', to: 'pages#about'
  get '/signup', to: 'users#signup'
  post '/signup', to: 'users#create'
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  resources :users

end
