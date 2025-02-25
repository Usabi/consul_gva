FactoryBot.define do
  factory :vmcrc_persona do
    codper { Faker::Number.number(digits: 5) }
    codmap { Faker::Number.number(digits: 3) }
    nomb { Faker::Name.first_name }
    ape1 { Faker::Name.last_name }
    ape2 { Faker::Name.last_name }
    dni { "#{Faker::Number.number(digits: 8)}#{[*"A".."Z"].sample}" }
    dcorreoint { Faker::Internet.email }
  end
end
