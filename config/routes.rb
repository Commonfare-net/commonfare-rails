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
    get :search, controller: :main
    get :autocomplete, controller: :main, defaults: { format: :json }
    resources :stories do
      # :index used for stories/42/comments, visible only by story's author
      resources :comments, only: [:index, :create]
      post :publish, on: :member
      get :preview, on: :member
    end
    get 'story_builder', to: 'stories#builder'

    resources :commoners do
      resources :stories, only: :index
      # :index used for commoner/42/comments, visible only by comments' author
      resources :comments, only: :index
      resources :images, only: [:create, :destroy]
    end
    resources :comments, except: [:new, :show, :index]
    resources :tags, only: :show
    resources :memberships
    resources :groups do
      resources :discussions do
        resources :messages, only: [:new, :create]
      end
      resources :join_requests, only: [:new, :create] do
        post :accept, on: :member
        post :reject, on: :member
      end
    end
    resources :join_requests, except: [:new, :create]

    get :welcome, controller: :commoners

    get "/pages/*id" => 'pages#show', as: :page, format: false
    root to: 'pages#show', id: 'home'
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
