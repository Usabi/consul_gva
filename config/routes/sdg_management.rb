namespace :sdg_management do
  root to: "goals#index"

  resources :goals, only: [:index, :edit] do
    post :update, on: :collection
  end
  resources :targets, only: [:index, :edit] do
    post :update, on: :collection
  end
  resources :local_targets, except: [:show]
  resource :homepage, controller: :homepage, only: [:show] do
    resource :header, controller: :header, only: [:new, :create, :edit, :update, :destroy]
  end

  resources :phases, only: [], as: :sdg_phases do
    resources :cards, except: [:index, :show], as: :widget_cards
  end

  types = SDG::Related::RELATABLE_TYPES.map(&:tableize)
  types_constraint = /#{types.join("|")}/

  get "*relatable_type", to: "relations#index", as: "relations", relatable_type: types_constraint
  get "*relatable_type/:id/edit", to: "relations#edit", as: "edit_relation", relatable_type: types_constraint
  patch "*relatable_type/:id", to: "relations#update", as: "relation", relatable_type: types_constraint

  types.each do |type|
    get type, to: "relations#index", as: type
    get "#{type}/:id/edit", to: "relations#edit", as: "edit_#{type.singularize}"
  end
end

resolve "SDG::LocalTarget" do |target, options|
  [:local_target, options.merge(id: target)]
end

resolve "SDG::Goal" do |goal, options|
  [:goal, options.merge(id: goal)]
end

resolve "SDG::Target" do |target, options|
  [:target, options.merge(id: target)]
end
