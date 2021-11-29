Rails.application.routes.draw do
  root 'games#home'
  resources :games, only: %i[new]
end
