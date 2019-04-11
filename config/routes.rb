Rails.application.routes.draw do

  # ************* ADMIN START **********
  devise_for :admin_users
  namespace :admin do
    resources :users
    resources :comments
    resources :commoners
    resources :images
    resources :stories
    resources :tags

    root to: "users#index"
  end
  # ************* ADMIN END **********

  devise_for :users,
    controllers: {
      sessions: 'users/sessions',
      registrations: 'users/registrations'
    },
    path: "auth",
    path_names: {
      sign_in: 'login',
      sign_out: 'logout',
      password: 'secret',
      confirmation: 'verification',
      unlock: 'unblock',
      registration: 'register',
      sign_up: 'signup'
    }

  devise_scope :user do
    # see https://github.com/plataformatec/devise/wiki/how-to:-define-resource-actions-that-require-authentication-using-routes.rb
    authenticate :user do
      get 'auth/goodbye', to: 'users/registrations#goodbye', as: 'goodbye'
    end
  end


  scope "(:locale)", locale: /en|it|nl|hr/ do
    notify_to :commoners, with_devise: :users
    get :search, controller: :main
    get :autocomplete, controller: :main, defaults: { format: :json }
    resources :stories do
      # :index used for stories/42/comments, visible only by story's author
      resources :comments, only: [:index, :create]
      post :publish, on: :member
      get :preview, on: :member
      get :templates, on: :collection
      get :recommend, on: :member, defaults: { format: :json }
    end
    get 'story_builder', to: 'stories#builder'

    # Usage: wallet_short_path(wallet_id)
    match 'w/:id', to: 'wallets#short_view', via: :get, as: 'wallet_short'
    resources :commoners, except: [:index] do
      resources :stories, only: :index
      # :index used for commoner/42/comments, visible only by comments' author
      resources :comments, only: :index
      resources :images, only: [:create, :destroy]
      # NOTE: uncomment to enable wallet
      if ENV['WALLET_ENABLED'] == 'true'
        resources :wallets, only: [:show] do
          get 'autocomplete', on: :collection, defaults: { format: :json }
          get 'view', on: :member
          get 'daily_takings', on: :member
        end
        post 'transaction_confirm', to: 'transactions#confirm', as: 'transaction_confirm'
        resources :transactions, except: [:edit, :update, :destroy] do
          get 'withdraw', on: :collection
          post 'confirm_withdraw', on: :collection
          post 'create_withdraw', on: :collection
          get 'top_up', on: :collection
          post 'confirm_top_up', on: :collection
          post 'create_top_up', on: :collection
          get 'success', on: :member
          get 'refund', on: :member
          post 'create_refund', on: :collection
        end
      end
      resources :listings, only: :index
    end
    resources :comments, except: [:new, :show, :index]
    resources :tags, only: :show
    resources :groups do
      resources :memberships, only: [:index, :edit, :update, :destroy]
      resources :discussions do
        resources :messages, only: [:create, :destroy]
      end
      resources :join_requests, only: [:new, :create] do
        post :accept, on: :member
        post :reject, on: :member
      end
      get :leave, on: :member
      get :affiliation, on: :member
      patch :affiliate, on: :member
      resources :currencies, except: [:index, :destroy]
      # NOTE: uncomment to enable wallet
      if ENV['WALLET_ENABLED'] == 'true'
        resources :wallets, only: [:show] do
          get 'autocomplete', on: :collection, defaults: { format: :json }
        end
        post 'transaction_confirm', to: 'transactions#confirm', as: 'transaction_confirm'
        get 'transaction_confirm', to: 'transactions#confirm'
        resources :transactions, except: [:edit, :update, :destroy]
      end
    end
    resources :conversations, except: [:edit, :update, :destroy] do
      resources :messages, only: [:create, :destroy]
    end
    resources :join_requests, except: [:new, :create]

    resources :listings do
      resources :comments, only: [:index, :create]
    end
    get :commonplace, controller: :listings

    get :welcome, controller: :commoners

    get "/pages/*id" => 'pages#show', as: :page, format: false
    root to: 'pages#show', id: 'home'
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
