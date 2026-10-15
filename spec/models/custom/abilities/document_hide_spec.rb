require "rails_helper"
require "cancan/matchers"

describe "Abilities for hiding comment documents" do
  let(:comment) { create(:comment) }
  let(:document) { create(:document, documentable: comment, user: comment.user) }

  it "lets administrators hide and restore a comment document" do
    ability = Ability.new(create(:administrator).user)

    expect(ability).to be_able_to(:hide, document)
    expect(ability).to be_able_to(:restore, document)
  end

  it "lets moderators hide and restore a comment document" do
    ability = Ability.new(create(:moderator).user)

    expect(ability).to be_able_to(:hide, document)
    expect(ability).to be_able_to(:restore, document)
  end

  it "does not let regular users hide documents" do
    ability = Ability.new(create(:user))

    expect(ability).not_to be_able_to(:hide, document)
  end

  it "does not let the comment author hide the document" do
    ability = Ability.new(comment.user)

    expect(ability).not_to be_able_to(:hide, document)
  end
end
