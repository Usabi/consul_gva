require "rails_helper"
require "cancan/matchers"

describe Abilities::Common do
  subject(:ability) { Ability.new(user) }

  let(:user) { create(:user, :level_two) }

  describe "legislation proposals edition" do
    let(:own_proposal) { create(:legislation_proposal, author: user) }
    let(:other_proposal) { create(:legislation_proposal) }
    let(:supported_own_proposal) do
      create(:legislation_proposal, author: user).tap { |p| create(:vote, votable: p) }.reload
    end

    it { should be_able_to(:edit, own_proposal) }
    it { should be_able_to(:update, own_proposal) }
    it { should_not be_able_to(:edit, other_proposal) }
    it { should_not be_able_to(:update, other_proposal) }
    it { should_not be_able_to(:edit, supported_own_proposal) }
    it { should_not be_able_to(:update, supported_own_proposal) }
  end
end
