require "rails_helper"
require "cancan/matchers"

describe "Abilities for deleting comment documents" do
  let(:comment) { create(:comment) }
  let(:document) { create(:document, documentable: comment, user: comment.user) }

  it "lets the comment author delete the document" do
    expect(Ability.new(comment.user)).to be_able_to(:destroy, document)
  end

  it "lets administrators delete a comment document" do
    expect(Ability.new(create(:administrator).user)).to be_able_to(:destroy, document)
  end

  it "lets moderators delete a comment document" do
    expect(Ability.new(create(:moderator).user)).to be_able_to(:destroy, document)
  end

  it "lets legislators delete only their own comment documents" do
    legislator = create(:legislator).user
    own = create(:document, documentable: create(:comment, user: legislator), user: legislator)

    expect(Ability.new(legislator)).to be_able_to(:destroy, own)
    expect(Ability.new(legislator)).not_to be_able_to(:destroy, document)
  end

  it "does not let other users delete the document" do
    expect(Ability.new(create(:user))).not_to be_able_to(:destroy, document)
  end
end
