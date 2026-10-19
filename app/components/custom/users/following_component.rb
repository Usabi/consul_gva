class Users::FollowingComponent < ApplicationComponent; end

load Rails.root.join("app", "components", "users", "following_component.rb")

class Users::FollowingComponent
  private

    def followable_icon(followable)
      {
        proposals: "Proposal",
        budget: "Budget::Investment",
        processes: "Legislation::Process"
      }.invert[followable]
    end
end
