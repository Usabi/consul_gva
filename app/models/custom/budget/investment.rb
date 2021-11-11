require_dependency Rails.root.join('app', 'models', 'budget', 'investment').to_s
# include Custom::BudgetsInvestmentsHelper

class Budget
  class Investment

    scope :not_selected, -> { where(feasibility: "not_selected") }
    # NOTE: This scope includes not_selected because is a filter used by default
    scope :not_unfeasible, -> { where.not(feasibility: ["unfeasible", "not_selected"]) }
    scope :supported, -> { joins(:heading).where("budget_investments.cached_votes_up + budget_investments.physical_votes >= budget_headings.min_supports") }

    def self.apply_filters_and_search(_budget, params, current_filter = nil)
      investments = all
      investments = investments.send(current_filter)             if current_filter.present? && (!params[:search].present? || !params[:search].to_i.positive? )
      investments = investments.by_heading(params[:heading_id])  if params[:heading_id].present?
      if params[:search].present?
        if params[:search].to_i.positive?
          params[:advanced_search] ||= {}
          params[:advanced_search][:id] = params[:search]
        else
          investments = investments.search(params[:search])
        end
      end

      if params[:advanced_search].present?
        investments = investments.search(params[:advanced_search][:tag]) if params[:advanced_search][:tag].present?
        investments = investments.filter(params[:advanced_search].reject { |k, v| k == "tag" })
      end
      investments
    end

    def self.advanced_filters(params, results)
      results = results.without_admin      if params[:advanced_filters].include?("without_admin")
      results = results.without_valuator   if params[:advanced_filters].include?("without_valuator")
      results = results.under_valuation    if params[:advanced_filters].include?("under_valuation")
      results = results.valuation_finished if params[:advanced_filters].include?("valuation_finished")
      results = results.winners            if params[:advanced_filters].include?("winners")
      results = results.supported          if params[:advanced_filters].include?("supported")

      ids = []
      ids += results.valuation_finished_feasible.pluck(:id) if params[:advanced_filters].include?("feasible")
      ids += results.where(selected: true).pluck(:id)       if params[:advanced_filters].include?("selected")
      ids += results.undecided.pluck(:id)                   if params[:advanced_filters].include?("undecided")
      ids += results.unfeasible.pluck(:id)                  if params[:advanced_filters].include?("unfeasible")
      ids += results.not_selected.pluck(:id)                if params[:advanced_filters].include?("not_selected")
      results = results.where(id: ids) if ids.any?
      results
    end

    def is_supported?
      total_votes >= heading.min_supports
    end

    def register_selection_vote_and_unvote(user, vote)
      if vote === "no"
        vote_by(voter: user, vote: vote)
      else
        vote_by(voter: user, vote: vote) if selectable_by?(user)
      end
    end

    def reason_for_not_being_selectable_by(user)
      return permission_problem(user) if permission_problem?(user)
      return :different_heading_assigned unless valid_heading?(user)
      return :max_votes_per_budget_per_user_limit_reached unless user.can_vote_budget_investment_for_this_budget?(self.budget_id)
      return :no_selecting_allowed unless budget.selecting?
    end

    def valid_heading?(user)
      (voted_in?(heading, user) || can_vote_in_another_heading?(user)) &&
      (group_voted_in?(group, user) || can_vote_in_another_group?(user))
    end

    def group_voted_in?(group, user)
      groups_voted_by_user(user).include?(group.id)
    end

    def groups_voted_by_user(user)
      user.votes.for_budget_investments(budget.investments).votables.map(&:group_id).uniq
    end

    def can_vote_in_another_group?(user)
      if has_votes_for_all_region?(user)
        groups_voted_by_user(user).count <= 2
      else
        groups_voted_by_user(user).count <= 1
      end
    end

    def has_votes_for_all_region?(user)
       all_city_group = budget.groups.first # NOTE: First group is all region
      if all_city_group&.headings&.size == 1
        user.votes.for_budget_investments(all_city_group.headings.first.investments).count > 0
      else
        false
      end
    end

    def not_selected?
      feasibility == "not_selected"
    end

    def not_selected_explanation_required?
      not_selected? && valuation_finished?
    end

    def not_selected_email_pending?
      not_selected_email_sent_at.blank? && not_selected? && valuation_finished?
    end

    def send_not_selected_email
      Mailer.budget_investment_not_selected(self).deliver_later
      update!(not_selected_email_sent_at: Time.current)
    end

    def should_show_aside?
      (budget.selecting? && !unfeasible? && !not_selected?) ||
        (budget.balloting? && feasible?) ||
        (budget.valuating? && !unfeasible? && !not_selected?)
    end

    def should_show_not_selected_explanation?
      not_selected? && valuation_finished? && not_selected_explanation.present?
    end
  end
end
