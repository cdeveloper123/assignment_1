Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  
  devise_for :users
  root 'budgets#index'
  
  resources :budgets do
    resources :budget_projects do
      member do
        patch :vote
        delete :remove_vote
      end
    end
    resources :budget_categories, only: [:index, :show]
    
    member do
      get :results
      get :admin_dashboard
    end
  end
  
  resources :voting_phases, only: [:index, :show]
  
  # Custom admin routes handled by ActiveAdmin
end 