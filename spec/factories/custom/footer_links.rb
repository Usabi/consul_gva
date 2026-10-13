FactoryBot.define do
  factory :footer_link do
    sequence(:label) { |n| "Footer link #{n}" }
    sequence(:url)   { |n| "https://www.gva.es/page-#{n}" }
    position { 0 }
    visible { true }
  end
end
