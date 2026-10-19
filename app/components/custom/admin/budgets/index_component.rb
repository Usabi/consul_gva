class Admin::Budgets::IndexComponent < ApplicationComponent; end

load Rails.root.join("app", "components", "admin","budgets", "index_component.rb")

class Admin::Budgets::IndexComponent
  delegate :can?, to: :helpers
end
