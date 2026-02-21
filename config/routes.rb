Rails.application.routes.draw do
  root "mangas#index"

  resources :mangas, only: [:index, :show] do
    resources :chapters, only: [:show]
  end

  # PWA routes
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
