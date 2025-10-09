FactoryBot.define do
  factory :citizen_opinion do
    topic { Custom::CitizenOpinionsHelper::TOPIC_GROUPS[:general][0] }
    name { Faker::Name.name }
    phone { Faker::PhoneNumber.phone_number }
    subject { Faker::Lorem.sentence }
    body { Faker::Lorem.paragraph }
    email { Faker::Internet.email }
  end
end
