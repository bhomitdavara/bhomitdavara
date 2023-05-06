Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  mount ActionCable.server => "/cable"

  root to: 'application#index'
  get '/about_app', to: 'apps#about'
  get '/privacy_policy', to: 'apps#policy'
  get '/terms_and_conditions', to: 'apps#terms'

  namespace :api, defaults: { format: :json } do
    namespace :v1 do

      get 'list_of_block_users', to: 'blocked_user#list_of_block_users'
      post 'block', to: 'blocked_user#block'
      delete 'unblock', to: 'blocked_user#unblock'
      post 'report', to: 'blocked_user#report'

      delete 'logout', to: 'users#logout'
      get 'health_check', to: 'users#health_check'
      resources :users, only: %i[create show] do
        post 'verify_otp', on: :member
        collection do
          patch 'update'
          post 'add_user'
        end
        get 'view_posts', controller: 'posts'
        get 'listing_view_posts', controller: 'posts'
      end

      resources :posts, except: %i[edit new] do
        # get 'view_posts', on: :collection
        collection do
          get :crop_wise_post
          get :listing_from
          get :listing_crop_wise_post
          get :listing_from_post
        end
        get :image_wise_measurement
        get :list_of_comments, controller: 'comments'
        resources :likes, controller: 'likes', only: [:create]
        resources :comments, controller: 'comments', only: %i[create index destroy] do
          resources :sub_comments, only: %i[create destroy]
        end
      end

      resources :product_types, only: [:index], shallow: true do
        resources :products, only: %i[index show]
      end

      resources :feedbacks, only: [:create]
      resources :complaints, only: [:create]
      get '/taged_products', to: 'products#taged_products'
      resources :problems, only: %i[index show]

      resources :fertilizer_schedules, only: [:index]
      resources :crop_categories, only: [:index] do
        get 'with_crops', on: :collection
      end
      get '/dropdown_option', to: 'users#dropdown_option'

      resources :messages, only: %i[index create]
    end
  end
end
