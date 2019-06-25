Rails.application.routes.draw do
  resources :short_urls, only: [:new, :create, :show]

  root 'short_urls#new'
end
