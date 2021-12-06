Rails.application.routes.draw do
  devise_for :users
  
  root to: 'games#home'

  #resources :games, only: %i[new] do
  resources :games do
    collection do
      get 'home'
    end
  end
end
