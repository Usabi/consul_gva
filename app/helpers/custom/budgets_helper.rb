module Custom::BudgetsHelper
  def heading_name_and_price_html(heading, budget)
    tag.div do
      concat(heading.name + " ")
      concat("(" + t("budgets.investments.investment.supports", count: heading.min_supports) + ")" + " ") if heading.min_supports
      concat(tag.span(budget.formatted_heading_price(heading)))
    end
  end

  def budgets_tabs
    tabs = {
      "budgets" => admin_budgets_path
    }
    if current_user&.administrator? || (current_user&.legislator? && current_user == process.user)
      tabs = tabs.merge({ "help_text" => help_page_admin_budgets_path })
    end
    tabs
  end
end
