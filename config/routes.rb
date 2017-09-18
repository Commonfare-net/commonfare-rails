Rails.application.routes.draw do
  devise_for :users
  devise_scope :user do
    # root to: 'devise/sessions#new'
  end
  scope "(:locale)", locale: /en|it|nl|hr/ do
    get :search, controller: :main
    resources :stories
    resources :commoners do
      resources :stories, only: [:index]
    end

    get "/pages/*id" => 'pages#show', as: :page, format: false
    root to: 'pages#show', id: 'home'
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
