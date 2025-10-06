module Abilities
  class Supporter
    include CanCan::Ability

    def initialize(user)
      merge Abilities::Common.new(user)

      can [:update], Legislation::Process

      can [:manage], ::Legislator

      can [:search, :index], ::User

      can :index, KeySystem
    end
  end
end
