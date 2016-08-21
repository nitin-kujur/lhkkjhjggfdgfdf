Rails.application.routes.draw do
  get 'sync_distributors' => "distributors#sync_distributors" , as: :sync_distributors
  resources :distributors
  root :to => 'orders#place_bulk_order'
  mount ShopifyApp::Engine, at: '/'

  namespace :app_proxy do
    root action: 'index'
    # simple routes without a specified controller will go to AppProxyController
    
    # more complex routes will go to controllers in the AppProxy namespace
    #   resources :reviews
    # GET /app_proxy/reviews will now be routed to
    # AppProxy::ReviewsController#index, for example
  end
  resources :orders
  get 'place_bulk_order' => 'orders#place_bulk_order' , as: :place_bulk_order
  get '/get_distributors' => 'distributors#get_distributors' , as: :get_distributors
  post '/set_distributors_for_bulk' => 'distributors#set_distributors_for_bulk' , as: :set_distributors_for_bulk
  get '/get_prd_for_distri/:distributor_id' => 'distributors#get_prd_for_distri' , as: :get_prd_for_distri
  post '/set_prd_for_distri' => 'distributors#set_prd_for_distri' , as: :set_prd_for_distri
  post '/bulk_order' => "orders#bulk_order" , as: :bulk_order
  get '/products' => "home#index" , as: :products

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
