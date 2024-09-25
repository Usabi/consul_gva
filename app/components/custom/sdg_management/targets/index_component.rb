class SDGManagement::Targets::IndexComponent < ApplicationComponent; end

require_dependency Rails.root.join("app", "components", "sdg_management", "targets", "index_component")

class SDGManagement::Targets::IndexComponent
  include Header

  attr_reader :targets

  def initialize(targets)
    @targets = targets
  end

  private

    def header_id(object)
      "#{dom_id(object)}_header"
    end

    def actions(target)
      render Admin::TableActionsComponent.new(target, actions: [:edit])
    end
end
