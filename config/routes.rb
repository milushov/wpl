Playlists::Application.routes.draw do
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
end
