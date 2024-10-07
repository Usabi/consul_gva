module Budgets
  class StatusExecutionsController < ApplicationController
    before_action :load_budget

    authorize_resource :budget

    def show
      authorize! :read_executions, @budget
      @statuses = Milestone::Status.all
      @investments = investments_ordered_alphabetically
    end

    private

      def investments
        base = @budget.investments.winners
        base = base.joins(milestones: :translations).includes(:milestones)
        base = base.tagged_with(params[:milestone_tag]) if params[:milestone_tag].present?
        base.distinct
      end

      def load_budget
        @budget = Budget.find_by_slug_or_id params[:budget_id]
      end

      def investments_ordered_alphabetically
        investments.sort_by(&:title)
      end
  end
end
