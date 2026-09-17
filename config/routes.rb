Rails.application.routes.draw do
  devise_for :users
  devise_for :admins
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Signed-in users land on the app at "/"
  authenticated :user do
    root to: "home#index", as: :user_root
  end

  # Signed-in admins land on the back-office at "/"
  authenticated :admin do
    root to: "admin#index", as: :admin_root
  end

  # Visitors hit HomeController's gate and are redirected to /users/sign_in
  root "home#index"

  get "admin" => "admin#index"
end
