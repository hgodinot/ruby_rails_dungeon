Rails.application.routes.draw do
  devise_for :users
  
  root to: 'games#index'

  #resources :users do
    resources :games#, only: %i[new, index] do
  #end
  
end
