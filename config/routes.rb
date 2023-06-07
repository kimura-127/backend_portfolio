Rails.application.routes.draw do
  resources :registration
  resources :getresult
  get '/home', to: 'home#index'
  resources :getvideo
  resources :sendanalyze
  post '/auth', to: 'sessions#create'
  get '/refresh', to: 'sessions#refresh'
end
