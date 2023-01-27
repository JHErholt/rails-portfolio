Rails.application.routes.draw do
  root "pages#home"

  get '/projects/', to: 'projects#index'
  get '/projects/:title', to: 'projects#show'
  get '/about/', to: 'pages#about'

  get '/test/', to: 'projects#index'
end
