Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  namespace :webhooks do
    match 'messages/:token' => 'messages#create', via: :post
  end
end
