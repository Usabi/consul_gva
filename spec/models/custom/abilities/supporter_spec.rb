require "rails_helper"
require "cancan/matchers"

describe Abilities::Supporter do
  subject(:ability) { Ability.new(user) }

  let(:user) { supporter.user }
  let(:supporter) { create(:supporter) }

  let(:debate) { create(:debate) }
  let(:proposal) { create(:proposal, author: user) }

  it { should be_able_to(:index, Debate) }
  it { should be_able_to(:show, debate) }

  it { should be_able_to(:index, Proposal) }
  it { should be_able_to(:show, proposal) }

  it { should_not be_able_to(:create, Budget) }
  it { should_not be_able_to(:update, Budget) }

  it { should_not be_able_to(:create, Budget::ValuatorAssignment) }

  it { should_not be_able_to(:admin_update, Budget::Investment) }

  it { should_not be_able_to(:hide, Budget::Investment) }

  it { should_not be_able_to(:manage, Dashboard::Action) }
end
