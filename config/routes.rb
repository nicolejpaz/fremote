Fremote::Application.routes.draw do
  devise_for :users
  root 'remotes#index'

  resources :remotes, only: [:index, :new, :create,:show,:update, :edit]
  resources :users, only: [:show]

  get 'remotes/:id/stream' => 'streams#stream'
  get 'remotes/:id/ping' => 'remotes#ping'
  post 'remotes/:id/clear' => 'drawings#clear'
  post 'remotes/:id/write' => 'drawings#write'
  put 'remotes/:id/drawings' => 'drawings#update'
  get 'remotes/:id/read' => 'drawings#read'
  get 'time' => 'remotes#time'
  put 'remotes/:id/control' => 'remotes#control'
  get 'how-it-works' => 'pages#how_it_works'
  get 'privacy-policy' => 'pages#privacy_policy'
  get 'terms-of-use' => 'pages#terms_of_use'
  match 'sitemap.xml', to: 'pages#sitemap', via: [:get, :post, :patch, :put, :delete], :defaults => {:format => :xml}
  get 'remotes/:id/chromecast-receiver' => 'casts#show'

  resources :remotes do
    resource :playlist, only: [:update, :show, :create, :destroy]
    resource :chat, controller: 'chat', only: [:create, :update]
  end

  match "/404", to: "errors#404_not_found", via: [:get, :post, :patch, :put, :delete]
  match "/422", to: "errors#422_unprocessable_entity", via: [:get, :post, :patch, :put, :delete]
  match "/500", to: "errors#500_internal_server_error", via: [:get, :post, :patch, :put, :delete]

end
