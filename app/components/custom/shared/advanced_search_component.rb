class Shared::AdvancedSearchComponent < ApplicationComponent; end

require_dependency Rails.root.join("app", "components", "shared", "advanced_search_component")

class Shared::AdvancedSearchComponent
  delegate :categories_search_options, to: :helpers
  delegate :resource_model, to: :helpers

  private

    def show?
      resource_model.name != "Debate"
    end
end
