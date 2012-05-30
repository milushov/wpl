Playlists::Application.routes.draw do

  # # TODO: make blacklist, like this
  # # http://guides.rubyonrails.org/routing.html

  # class BlacklistConstraint
  #   def initialize
  #     @ips = Blacklist.retrieve_ips
  #   end
   
  #   def matches?(request)
  #     @ips.include?(request.remote_ip)
  #   end
  # end
   
  # TwitterClone::Application.routes.draw do
  #   match "*path" => "blacklist#index",
  #     :constraints => BlacklistConstraint.new
  # end

  scope 'api' do
    resources :playlists do 
      collection do
        get 'last'
        get 'popular'
        get 'tags'
        get 'tags/:tag', to: 'playlists#playlistsByTag'
        get 'search/:query', to:'playlists#search'
      end

      member do
        get 'follow'
        get 'unfollow'
        get 'comments', to: 'comments#index'
        post 'comments/create', to: 'comments#create'
        post 'comments/:cid/update', to: 'comments#update'
        post 'comments/:cid/delete', to: 'comments#delete'
        post 'comments/:cid/spam', to: 'comments#spam'
      end

      resources :tracks do
        member do
          get 'like'
          get 'hate'
        end
      end
    end

    resources :users do
      member do
        get 'follow'
        get 'unfollow'
      end
    end
  end

  get 'u/:id', to: 'main#index'
  get 'auth', to: 'main#auth'
  get 'login', to: 'main#login'
  get 'logout', to: 'main#logout'

  root to: 'main#index'
  get '*path', to: 'main#index'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
