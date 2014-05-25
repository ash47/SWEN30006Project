ClubBiz::Application.routes.draw do

  resources :clubs

  devise_for :users
  root to: 'clubs#index'

  # User joining a club
  get '/clubs/:id/join', to: 'clubs#join', as: 'join_club'

  # Leaving a club
  get '/clubs/:id/leave', to: 'clubs#leave', as: 'leave_club'

  # DEBUG: ADD/REMOVE AN ADMIN
  get '/become_admin', to: 'admin#become_admin', as: 'become_admin'
  get '/remove_admin', to: 'admin#remove_admin', as: 'remove_admin'

  # Admin stuff
  get '/admin', to: 'admin#index', as: 'admin'
  get '/admin/verify/:id', to: 'admin#verify', as: 'verify_club'
  patch '/admin/verify/:id', to: 'admin#verify'

  # Events stuff
  get '/events', to: 'events#index', as: 'search_events'
  get '/events/create/:id/:stage', to: 'events#create', as: 'create_event'
  get '/events/:id', to: 'events#show', as: 'event'
  get '/events/:id/tickets', to: 'events#tickets', as: 'reserve_tickets'

  # Profile stuff
  get '/profile', to: 'profile#index', as: 'profile'
  get '/messages/:id/delete', to: 'profile#delete_message', as: 'delete_message'

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
