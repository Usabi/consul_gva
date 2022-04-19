class Ability
  include CanCan::Ability

  def initialize(user)
    # If someone can hide something, he can also hide it
    # from the moderation screen
    alias_action :hide_in_moderation_screen, to: :hide

    can :users_count, User

    if user # logged-in users
      merge Abilities::Valuator.new(user) if user.valuator?

      if user.administrator?
        merge Abilities::Administrator.new(user)
        can [:manage], ::Milestone::Status
        can [:manage], ::Legislator
        can [:manage], ::BudgetManager
      elsif user.legislator?
        merge Abilities::Legislator.new(user)
      elsif user.budget_manager?
        merge Abilities::BudgetManager.new(user)
      elsif user.moderator?
        merge Abilities::Moderator.new(user)
      elsif user.manager?
        merge Abilities::Manager.new(user)
      elsif user.sdg_manager?
        merge Abilities::SDG::Manager.new(user)
      else
        merge Abilities::Common.new(user)
      end
    else
      merge Abilities::Everyone.new(user)
    end
  end
end
