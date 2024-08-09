class SDGManagement::Goals::IndexComponent < ApplicationComponent; end

require_dependency Rails.root.join("app", "components", "sdg_management", "goals", "index_component")

class SDGManagement::Goals::IndexComponent
  include Header

  attr_reader :goals

  def initialize(goals)
    @goals = goals
  end

  private

    def header_id(object)
      "#{dom_id(object)}_header"
    end

    def actions(goal)
      render Admin::TableActionsComponent.new(goal, actions: [:edit])
    end
end
