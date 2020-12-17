module Abilities
  class Legislator
    include CanCan::Ability

    def initialize(user)
      can :create, Legislation::Proposal
      can :show, Legislation::Proposal
      can :proposals, ::Legislation::Process

      can :restore, Legislation::Proposal
      cannot :restore, Legislation::Proposal, hidden_at: nil

      can :confirm_hide, Legislation::Proposal
      cannot :confirm_hide, Legislation::Proposal, hidden_at: nil

      can :comment_as_administrator, [Legislation::Question, Legislation::Proposal, Legislation::Annotation]

      can [:read, :debate, :draft_publication, :allegations, :result_publication,
          :milestones], Legislation::Process
      can [:create, :update, :destroy], Legislation::Process
      can [:manage], ::Legislation::DraftVersion
      can [:manage], ::Legislation::Question
      can [:manage], ::Legislation::Proposal
      cannot :comment_as_moderator, [::Legislation::Question, Legislation::Annotation, ::Legislation::Proposal]
    end
  end
end
