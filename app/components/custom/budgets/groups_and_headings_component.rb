class Budgets::GroupsAndHeadingsComponent < ApplicationComponent; end

load Rails.root.join("app", "components", "budgets", "groups_and_headings_component.rb")

class Budgets::GroupsAndHeadingsComponent

  private

  def heading_name(heading)
    tag.div do
      concat(heading.name + " ")
      concat("(" + t("budgets.investments.investment.supports", count: heading.min_supports) + ")" + " ") if heading.min_supports
    end
  end
end
