Rails.application.routes.draw do
  root 'games#home'
  get  'games/new'
  #get 'new', to: 'games#new'
  #resources :games, only: %i[new]
end
