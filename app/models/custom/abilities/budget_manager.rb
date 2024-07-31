module Abilities
  class BudgetManager
    include CanCan::Ability

    def initialize(user)
      merge Abilities::Common.new(user)

      can :comment_as_administrator, [Budget::Investment]

      can [:index, :read], Budget
      can [:read], Budget::Group
      can [:read], Budget::Heading
      can [:hide, :admin_update, :toggle_selection], Budget::Investment
      can [:valuate, :comment_valuation], Budget::Investment
      can [:toggle_winner], Budget::Investment, budget: { phase: ["reviewing_ballots", "finished"] }
      cannot [:admin_update, :toggle_selection, :valuate, :comment_valuation],
             Budget::Investment, budget: { phase: "finished" }

      can :create, Budget::ValuatorAssignment
    end
  end
end
