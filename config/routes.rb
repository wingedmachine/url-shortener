Rails.application.routes.draw do
  root 'short_urls#new'
  post '/short_urls', to: 'short_urls#create'
  get '/*shortened_url', to: 'short_urls#redirect'
end
