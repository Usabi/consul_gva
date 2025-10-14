FactoryBot.define do
  factory :management_newsletter do
    status { :pending }
  end

  factory :management_newsletter_proposal do
    management_newsletter
    proposal
  end

  factory :management_newsletter_investment do
    management_newsletter
    investment factory: budget_investment
  end

  factory :management_newsletter_debate do
    management_newsletter
    debate
  end
end
