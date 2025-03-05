FactoryBot.define do
  factory :alert_message do
    sequence(:title)     { |n| "Milestone #{n} title" }
    description          { "Milestone description" }
  end
end
