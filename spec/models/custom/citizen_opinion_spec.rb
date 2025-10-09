require "rails_helper"

RSpec.describe CitizenOpinion do
  let(:citizen_opinion) { build(:citizen_opinion) }

  describe "validations" do
    it "is valid with all required attributes" do
      expect(citizen_opinion).to be_valid
    end

    describe "#topic" do
      it "is not valid without a topic" do
        citizen_opinion.topic = nil
        expect(citizen_opinion).not_to be_valid
      end

      it "is not valid with an empty topic" do
        citizen_opinion.topic = ""
        expect(citizen_opinion).not_to be_valid
      end
    end

    describe "#body" do
      it "is not valid without a body" do
        citizen_opinion.body = nil
        expect(citizen_opinion).not_to be_valid
      end

      it "is not valid with an empty body" do
        citizen_opinion.body = ""
        expect(citizen_opinion).not_to be_valid
      end
    end

    describe "#email" do
      it "is not valid without an email" do
        citizen_opinion.email = nil
        expect(citizen_opinion).not_to be_valid
      end

      it "is not valid with an empty email" do
        citizen_opinion.email = ""
        expect(citizen_opinion).not_to be_valid
      end

      it "is not valid with an invalid email format" do
        invalid_emails = ["test", "test@", "@test.com", "test@test", "test.com"]

        invalid_emails.each do |email|
          citizen_opinion.email = email
          expect(citizen_opinion).not_to be_valid
        end
      end

      it "is valid with a valid email format" do
        valid_emails = ["test@test.com", "user.name@domain.com", "user+label@domain.co.uk"]

        valid_emails.each do |email|
          citizen_opinion.email = email
          expect(citizen_opinion).to be_valid
        end
      end
    end
  end

  describe "pagination" do
    it "paginates with 25 records per page" do
      expect(CitizenOpinion.default_per_page).to eq(25)
    end
  end
end
