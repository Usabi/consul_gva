FactoryBot.define do
  factory :citizen_newsletter do
    status { :pending }
  end

  factory :citizen_newsletter_proposal do
    citizen_newsletter
    proposal
  end

  factory :citizen_newsletter_debate do
    citizen_newsletter
    debate
  end

  factory :citizen_newsletter_preview_process do
    citizen_newsletter
    process factory: :legislation_process
  end

  factory :citizen_newsletter_public_process do
    citizen_newsletter
    process factory: :legislation_process
  end
end
