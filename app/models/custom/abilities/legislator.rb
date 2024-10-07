module Abilities
  class Legislator
    include CanCan::Ability

    def initialize(user)
      merge Abilities::Common.new(user)

      can :create, Legislation::Proposal
      can :show, Legislation::Proposal
      can :proposals, ::Legislation::Process

      can :restore, Legislation::Proposal
      cannot :restore, Legislation::Proposal, hidden_at: nil

      can :confirm_hide, Legislation::Proposal
      cannot :confirm_hide, Legislation::Proposal, hidden_at: nil

      can :comment_as_administrator, [Legislation::Question, Legislation::Annotation, Legislation::Proposal]

      can [:read, :debate, :draft_publication, :allegations, :result_publication,
          :milestones], Legislation::Process, user_id: user.id
      can [:read, :debate, :draft_publication, :allegations, :result_publication,
      :milestones], Legislation::Process, legislators: { id: user&.legislator&.id }


      can [:create], Legislation::Process
      can [:update, :destroy], Legislation::Process do |process|
        process.user_id == user.id || process.legislator_ids.include?(user&.legislator&.id)
      end
      can [:manage], ::Legislation::DraftVersion
      can [:manage], ::Legislation::Question
      can [:manage], ::Legislation::Proposal
      cannot :comment_as_moderator, [::Legislation::Question, Legislation::Annotation, ::Legislation::Proposal]

      cannot [:manage], ::Milestone::Status
    end
  end
end
