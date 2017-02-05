Rails.application.routes.draw do
  # uses custom controller for registrations
  devise_for :users, :controllers => {registrations: 'registrations'}
  root 'welcome#index'
  resources :companies 
  resources :jobs
  resources :applies
  resources :tags
  resources :posts

  # resources :users, only: [:edit_password]

  # Other non-resourceful routes
  get "/recruiter", :to => redirect("/recruiter.html")
  get 'search', to: 'search#search'
  get '/users/edit_password', to: 'user#edit_password'

  get 'static_pages/adminpanel'

  get 'static_pages/faq'

  get 'static_pages/about'

  get 'static_pages/feedback'

  get 'static_pages/press'

  get 'static_pages/howitworks'

  get 'static_pages/careers'

  get 'static_pages/product'

  get 'category', :to => 'jobs#category'
end
