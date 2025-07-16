get "/users_count.json", to: "users#users_count"

resources :budgets, only: [:show, :index] do
  # resources :groups, controller: "budgets/groups", only: [:show]
  resources :investments, controller: "budgets/investments", only: [:index, :new, :create, :show, :destroy] do
    member do
      post :vote
      post :unvote
      put :flag
      put :unflag
    end
  end
end

namespace :admin do
  resources :legislators, only: [:index, :create, :destroy] do
    get :search, on: :collection
  end
  resources :budget_managers, only: [:index, :create, :destroy] do
    get :search, on: :collection
  end
end
