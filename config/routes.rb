Fremote::Application.routes.draw do
  devise_for :users
  root 'remotes#new'

  resources :remotes, only: [:create,:show,:update]
  resources :users, only: [:show]

  get 'remotes/:id/stream' => 'streams#stream'
  get 'remotes/:id/ping' => 'remotes#ping'
  post 'remotes/:id/clear' => 'drawings#clear'
  post 'remotes/:id/write' => 'drawings#write'
  put 'remotes/:id/drawings' => 'drawings#update'
  get 'remotes/:id/read' => 'drawings#read'
  get 'time' => 'remotes#time'
  put 'remotes/:id/control' => 'remotes#control'

  resources :remotes do
    resource :playlist, only: [:update, :show, :create, :destroy]
    resource :chat, controller: 'chat', only: [:create, :update]
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
