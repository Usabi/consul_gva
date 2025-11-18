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

  describe "citizen newsletter preferences" do
    describe "#subscribed_to_any_citizen_newsletter?" do
      it "returns false when no preferences are enabled" do
        user = create(:user, newsletter_debates: false, newsletter_proposals: false,
                             newsletter_legislation: false)
        expect(user.subscribed_to_any_citizen_newsletter?).to be false
      end

      it "returns true when at least one preference is enabled" do
        user = create(:user, newsletter_debates: true, newsletter_proposals: false,
                             newsletter_legislation: false)
        expect(user.subscribed_to_any_citizen_newsletter?).to be true
      end
    end

    describe "#citizen_newsletter_preferences" do
      it "returns a hash with all preferences" do
        user = create(:user, newsletter_debates: true, newsletter_proposals: false,
                             newsletter_legislation: true)
        preferences = user.citizen_newsletter_preferences

        expect(preferences[:debates]).to be true
        expect(preferences[:proposals]).to be false
        expect(preferences[:legislation]).to be true
      end
    end
  end

  describe "scopes" do
    describe ".newsletter_debates_subscribers" do
      it "returns users subscribed to debates newsletter" do
        user1 = create(:user, newsletter: true, newsletter_debates: true)
        user2 = create(:user, newsletter: true, newsletter_debates: false)
        user3 = create(:user, newsletter: false, newsletter_debates: true)

        expect(User.newsletter_debates_subscribers).to include(user1)
        expect(User.newsletter_debates_subscribers).not_to include(user2)
        expect(User.newsletter_debates_subscribers).not_to include(user3)
      end
    end

    describe ".newsletter_proposals_subscribers" do
      it "returns users subscribed to proposals newsletter" do
        user1 = create(:user, newsletter: true, newsletter_proposals: true)
        user2 = create(:user, newsletter: true, newsletter_proposals: false)

        expect(User.newsletter_proposals_subscribers).to include(user1)
        expect(User.newsletter_proposals_subscribers).not_to include(user2)
      end
    end

    describe ".newsletter_legislation_subscribers" do
      it "returns users subscribed to legislation newsletter" do
        user1 = create(:user, newsletter: true, newsletter_legislation: true)
        user2 = create(:user, newsletter: true, newsletter_legislation: false)

        expect(User.newsletter_legislation_subscribers).to include(user1)
        expect(User.newsletter_legislation_subscribers).not_to include(user2)
      end
    end
  end
end
