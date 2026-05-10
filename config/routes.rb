Rails.application.routes.draw do
  root "explore#index"

  # Explore (nova homepage + categorias)
  get "explore", to: "explore#index", as: :explore
  get "explore/category", to: "explore#category", as: :explore_category

  # Mangás locais (catálogo existente)
  resources :mangas, only: [ :index, :show ] do
    resources :chapters, only: [ :show ]
  end

  # API JSON para o app mobile (Expo/React Native)
  namespace :api do
    namespace :v1, defaults: { format: :json } do
      get "explore", to: "explore#index"
      get "explore/category", to: "explore#category"

      resources :mangas, only: [ :index, :show ] do
        resources :chapters, only: [ :show ]
      end

      resources :reading_histories, only: [ :index, :create ]
    end
  end

  # PWA routes
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
