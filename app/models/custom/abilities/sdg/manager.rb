class Abilities::SDG::Manager
  include CanCan::Ability

  def initialize(user)
    merge Abilities::Common.new(user)

    can [:read, :edit, :update], ::SDG::Target
    can [:read, :edit, :update], ::SDG::Goal
    can :manage, ::SDG::LocalTarget
    can :read, WebSection, name: "sdg"
    can [:create, :update, :destroy], Widget::Card do |card|
      card.cardable_type == "SDG::Phase" || card.cardable&.name == "sdg"
    end
  end
end
