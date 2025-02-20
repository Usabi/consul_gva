load Rails.root.join("app", "models", "milestone", "status.rb")

class Milestone::Status
  translates :name, touch: true
  translates :description, touch: true
  include Globalizable

  validates_translation :name, presence: true
end
