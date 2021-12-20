Rails.application.routes.draw do
  devise_for :users
  
  root to: 'games#index'

  resources :games, only: %i[index show create destroy update] do
    member do
      patch :play_again
      patch :choose
      patch :start
    end
  end

  get '*path' => redirect('/')
end


