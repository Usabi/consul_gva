require "rails_helper"

describe UserSegments do
  describe ".segments" do
    it "includes citizen newsletter segments" do
      expect(UserSegments.segments).to include("newsletter_debates")
      expect(UserSegments.segments).to include("newsletter_proposals")
      expect(UserSegments.segments).to include("newsletter_legislation")
    end
  end

  describe ".newsletter_debates" do
    it "returns users subscribed to debates newsletter" do
      user1 = create(:user, newsletter: true, newsletter_debates: true)
      user2 = create(:user, newsletter: true, newsletter_debates: false)
      user3 = create(:user, newsletter: false, newsletter_debates: true)

      result = UserSegments.newsletter_debates

      expect(result).to include(user1)
      expect(result).not_to include(user2)
      expect(result).not_to include(user3)
    end
  end

  describe ".newsletter_proposals" do
    it "returns users subscribed to proposals newsletter" do
      user1 = create(:user, newsletter: true, newsletter_proposals: true)
      user2 = create(:user, newsletter: true, newsletter_proposals: false)

      result = UserSegments.newsletter_proposals

      expect(result).to include(user1)
      expect(result).not_to include(user2)
    end
  end

  describe ".newsletter_legislation" do
    it "returns users subscribed to legislation newsletter" do
      user1 = create(:user, newsletter: true, newsletter_legislation: true)
      user2 = create(:user, newsletter: true, newsletter_legislation: false)

      result = UserSegments.newsletter_legislation

      expect(result).to include(user1)
      expect(result).not_to include(user2)
    end
  end

  describe ".recipients" do
    it "returns users for newsletter_debates segment" do
      user1 = create(:user, newsletter: true, newsletter_debates: true)
      user2 = create(:user, newsletter: true, newsletter_debates: false)

      result = UserSegments.recipients("newsletter_debates")

      expect(result).to include(user1)
      expect(result).not_to include(user2)
    end

    it "returns users for newsletter_proposals segment" do
      user1 = create(:user, newsletter: true, newsletter_proposals: true)
      user2 = create(:user, newsletter: true, newsletter_proposals: false)

      result = UserSegments.recipients("newsletter_proposals")

      expect(result).to include(user1)
      expect(result).not_to include(user2)
    end

    it "returns users for newsletter_legislation segment" do
      user1 = create(:user, newsletter: true, newsletter_legislation: true)
      user2 = create(:user, newsletter: true, newsletter_legislation: false)

      result = UserSegments.recipients("newsletter_legislation")

      expect(result).to include(user1)
      expect(result).not_to include(user2)
    end

    it "handles multiple segments including citizen newsletter segments" do
      user1 = create(:user, newsletter: true, newsletter_debates: true, newsletter_proposals: false)
      user2 = create(:user, newsletter: true, newsletter_debates: false, newsletter_proposals: true)
      user3 = create(:user, newsletter: true, newsletter_debates: false, newsletter_proposals: false)

      result = UserSegments.recipients(["newsletter_debates", "newsletter_proposals"])

      expect(result).to include(user1)
      expect(result).to include(user2)
      expect(result).not_to include(user3)
    end
  end
end
