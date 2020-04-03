Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'users#index'
  # post '', to: 'users#index'
  match '/bot', to: 'users#index', via: :post
end
