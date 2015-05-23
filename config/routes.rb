Rails.application.routes.draw do
  root to: 'visitors#index'
  resources :judges do
    resources :admissions
  end

end
