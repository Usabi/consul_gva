load Rails.root.join("app", "models", "concerns", "statisticable.rb")

module Statisticable
  class_methods do
    def gender_methods
      %i[total_male_participants total_female_participants total_other_participants male_percentage female_percentage other_percentage]
    end
  end

  def gender?
    participants.male.any? || participants.female.any? || participants.other.any?
  end

  def total_other_participants
    participants.other.count
  end

  def other_percentage
    calculate_percentage(total_other_participants, total_participants_with_gender)
  end
end
