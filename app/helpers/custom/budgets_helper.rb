module Custom::BudgetsHelper
  def heading_name_and_price_html(heading, budget)
    tag.div do
      concat(heading.name + " ")
      concat("(" + t("budgets.investments.investment.supports", count: heading.min_supports) + ")" + " ") if heading.min_supports
      concat(tag.span(budget.formatted_heading_price(heading)))
    end
  end
end
