Rails.application.routes.draw do
  root 'games#home'
  get  'games/new'
end
