FactoryBot.define do
  factory :legislation_council, class: "Legislation::Council" do
    title { Faker::Company.name }
    active { true }

    trait :inactive do
      active { false }
    end
  end
end
