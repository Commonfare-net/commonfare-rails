Rails.application.routes.draw do
  devise_for :users
  devise_scope :user do
    root to: 'devise/sessions#new'
  end
  scope "(:locale)", locale: /en|it|nl|hr/ do
    resources :stories
    resources :commoners do
      resources :stories, only: [:index]
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
