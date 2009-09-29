ActionController::Routing::Routes.draw do |map|
  map.resources :users

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  #map.root :controller => "tweets"
  map.root :controller => "tweets"
  
  map.resource :session
  map.signin '/signin', :controller => 'sessions', :action => 'new'
  map.signout '/signout', :controller => 'sessions', :action => 'destroy'
  map.callback '/callback', :controller => 'users', :action => 'callback'
  map.twitter_oauth '/twitter_oauth', :controller => 'users', :action => 'twitters'
  map.firehose '/firehose', :controller => 'tweets', :action => 'firehose'
  map.export '/export', :controller => 'users', :action => 'export'
  
  map.auto_complete ':controller/:action', 
                  :requirements => { :action => /auto_complete_for_\S+/ },
                  :conditions => { :method => :get }
  
	map.connect '/', :controller => "tweets"

  map.connect '/:id', :controller => "tweets", :action => "show", :format => "html"
  map.connect '/:id.:format', :controller => "tweets", :action => "show"
  # See how all your routes lay out with "rake routes"

  map.connect 'tweets/create.text', :controller => "tweets", :action => "create", :format => "text"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
