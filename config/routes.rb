Rails.application.routes.draw do
  root "applications#index"
  resources :applications, only: [:index, :show, :create, :update], param: :token do
    resources :chats, only: [:index, :show, :create], param: :number do
      resources :messages, only: [:index, :show, :create, :update], param: :number
    end
  end
end
