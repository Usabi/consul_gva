FactoryBot.define do
  factory :bulletin do
    title { Faker::Lorem.sentence }
    template { "proposal" }
  end
end
