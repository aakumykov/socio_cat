Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#home'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase
  get 'home' => 'welcome#home', as: :home
  get 'help' => 'welcome#help', as: :help
  get 'about' => 'welcome#about', as: :about

  get 'register' => 'users#new', as: :register
  
  get 'login' => 'sessions#new', as: :login
  delete 'logout' => 'sessions#destroy', as: :logout

  get 'reset_password' => 'users#reset_password'
  post 'reset_request' => 'users#reset_request'
  get 'reset_response' => 'users#reset_response'
  get 'new_password' => redirect('/')
  post 'new_password' => 'users#new_password'

  get 'activation' => 'users#activation'
  post 'activation_request' => 'users#activation_request'

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products
  resources :users
  resources :sessions, only: [:new, :create, :destroy]
  resources :categories
  resources :cards do
    member do
      post 'categorize'
    end
  end

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
