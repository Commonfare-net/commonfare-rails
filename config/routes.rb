Rails.application.routes.draw do

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

  scope "(:locale)", locale: /en|it|nl|hr/ do
    get :search, controller: :main
    get :autocomplete, controller: :main, defaults: { format: :json }
    resources :stories do
      # :index used for stories/42/comments, visible only by story's author
      resources :comments, only: [:index, :create]
    end
    resources :commoners do
      resources :stories, only: :index
      # :index used for commoner/42/comments, visible only by comments' author
      resources :comments, only: :index
    end
    resources :comments, except: [:new, :show, :index]
    resources :tags, only: :show

    get :welcome, controller: :commoners

    get "/pages/*id" => 'pages#show', as: :page, format: false
    root to: 'pages#show', id: 'home'
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
