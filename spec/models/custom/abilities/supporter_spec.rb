require "rails_helper"
require "cancan/matchers"

describe Abilities::Supporter do
  subject(:ability) { Ability.new(user) }

  let(:user) { supporter.user }
  let(:supporter) { create(:supporter) }
end
