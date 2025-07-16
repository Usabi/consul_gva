require "rails_helper"
require "cancan/matchers"

describe Abilities::Administrator do
  subject(:ability) { Ability.new(user) }

  let(:user) { administrator.user }
  let(:administrator) { create(:administrator) }
  let(:past_draft_process) { create(:legislation_process, :past, :not_published) }
  let(:open_process) { create(:legislation_process, :open) }

  it { should be_able_to(:summary, past_draft_process) }
  it { should be_able_to(:summary, open_process) }
end
