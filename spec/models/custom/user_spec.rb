require "rails_helper"

describe User do
  subject { build(:user) }

  describe "supporter?" do
    it "is false when the user is not an supporter" do
      expect(subject.supporter?).to be false
    end

    it "is true when the user is an supporter" do
      subject.save!
      create(:supporter, user: subject)
      expect(subject.supporter?).to be true
    end
  end
end
