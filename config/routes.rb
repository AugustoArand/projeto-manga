Rails.application.routes.draw do
  root "explore#index"

  # Explore (nova homepage + categorias)
  get "explore", to: "explore#index", as: :explore
  get "explore/category", to: "explore#category", as: :explore_category

  # Perfil e Planos
  get "perfil", to: "profiles#show", as: :profile
  get "planos", to: "plans#show", as: :plans

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

      # Usuários MangaVerse
      post  "users/register",       to: "users#register"
      post  "users/login",          to: "users#login"
      delete "users/logout",        to: "users#logout"
      get   "users/me",             to: "users#me"
      patch "users/me",             to: "users#update_profile"

      # MangaDex proxy — leitura de mangás e capítulos diretamente da API
      get "mdex/search",      to: "mdex#search",  as: :mdex_search
      get "mdex/manga/:id",   to: "mdex#manga",   as: :mdex_manga
      get "mdex/chapter/:id", to: "mdex#chapter", as: :mdex_chapter

      # Auth (proxy OAuth para MangaDex)
      post "auth/login",   to: "auth#login"
      post "auth/refresh", to: "auth#refresh"

      # MDList — status de leitura e listas customizadas
      scope :mdlist do
        post   "status/:manga_id",  to: "mdlist#set_status"
        get    "status/:manga_id",  to: "mdlist#get_status"
        post   "follow/:manga_id",  to: "mdlist#follow"
        delete "follow/:manga_id",  to: "mdlist#unfollow"
        get    "lists",             to: "mdlist#index"
        post   "lists",             to: "mdlist#create"
        put    "lists/:id",         to: "mdlist#update"
      end

      # Upload de capítulos
      scope :upload do
        get    "session",                          to: "upload#session"
        post   "begin",                            to: "upload#begin"
        post   ":session_id/pages",               to: "upload#add_pages"
        delete ":session_id/pages/:file_id",      to: "upload#delete_page"
        post   ":session_id/commit",              to: "upload#commit"
        delete ":session_id",                     to: "upload#abandon"
      end

      # Criação de mangá e capa
      scope :manga_drafts do
        get  "/",       to: "manga_drafts#index"
        post "/",       to: "manga_drafts#create"
        post ":id/cover",  to: "manga_drafts#upload_cover"
        post ":id/submit", to: "manga_drafts#submit"
      end
    end
  end

  # PWA routes
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
