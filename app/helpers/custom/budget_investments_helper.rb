module Custom::BudgetInvestmentsHelper
  def progress_bar_percentage_investment(investment)
    min_supports = investment.heading.min_supports || 0
    case investment.total_votes
    when 0 then 0
    when 1..min_supports then (investment.total_votes.to_f * 100 / min_supports).floor
    else 100
    end
  end

  def supports_percentage_investment(investment)
    min_supports = investment.heading.min_supports || 0
    percentage = (investment.total_votes.to_f * 100 / min_supports) || 0
    case percentage
    when 0 then "0%"
    when 0..0.1 then "0.1%"
    when 0.1..100 then number_to_percentage(percentage, strip_insignificant_zeros: true, precision: 1)
    else "100%"
    end
  end
end
