Rails.application.routes.draw do

  get 'password_resets/new'

  get 'password_resets/edit'

  root 'pages#home'
  get '/about', to: 'pages#about'
  get '/signup', to: 'users#signup'
  post '/signup', to: 'users#create'
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  resources :users do
    member do
      get :following, :followers
    end
    # an alternative is collection, but it displays all the whatever in the application and not solely the user's
  end
  resources :microposts, only: [:create, :edit, :update, :destroy]
  # since the Micropost resource will run through the profile and home pages, we won't need actions like new or edit
  resources :relationships, only: [:create, :destroy]

  resources :password_resets, only: [:new, :create, :edit, :update]

end
