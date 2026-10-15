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

    describe "with the proposals phase closed" do
      before { own_proposal.process.update!(proposals_phase_end_date: Date.yesterday) }

      it { should_not be_able_to(:edit, own_proposal.reload) }
      it { should_not be_able_to(:update, own_proposal.reload) }
    end

    describe "privileged roles" do
      let(:supported) do
        create(:legislation_proposal).tap { |p| create(:vote, votable: p) }.reload
      end
      let(:closed) do
        create(:legislation_proposal).tap do |p|
          p.process.update!(proposals_phase_end_date: Date.yesterday)
        end.reload
      end

      [:administrator, :legislator].each do |role|
        context role.to_s do
          subject(:ability) { Ability.new(create(role).user) }

          it { should_not be_able_to(:edit, supported) }
          it { should_not be_able_to(:update, supported) }
          it { should_not be_able_to(:edit, closed) }
          it { should_not be_able_to(:update, closed) }
        end
      end
    end
  end
end
