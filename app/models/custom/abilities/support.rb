module Abilities
  class Support
    include CanCan::Ability

    def initialize(user)
      merge Abilities::Common.new(user)
    end
  end
end
