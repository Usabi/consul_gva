require "rails_helper"
require "cancan/matchers"

describe Abilities::Common do
  subject(:ability) { Ability.new(user) }

  let(:geozone)     { create(:geozone)  }

  let(:user) { create(:user, geozone: geozone) }

  let(:debate)       { create(:debate)   }
  let(:comment)      { create(:comment)  }
  let(:proposal)     { create(:proposal) }
  let(:own_debate)   { create(:debate,   author: user) }
  let(:own_comment)  { create(:comment,  author: user) }
  let(:own_proposal) { create(:proposal, author: user) }
  let(:own_legislation_proposal) { create(:legislation_proposal, author: user) }

  let(:accepting_budget) { create(:budget, :accepting) }
  let(:reviewing_budget) { create(:budget, :reviewing) }
  let(:selecting_budget) { create(:budget, :selecting) }
  let(:balloting_budget) { create(:budget, :balloting) }

  let(:investment_in_accepting_budget) { create(:budget_investment, budget: accepting_budget) }
  let(:investment_in_reviewing_budget) { create(:budget_investment, budget: reviewing_budget) }
  let(:investment_in_selecting_budget) { create(:budget_investment, budget: selecting_budget) }
  let(:investment_in_balloting_budget) { create(:budget_investment, budget: balloting_budget) }
  let(:own_investment_in_accepting_budget) { create(:budget_investment, budget: accepting_budget, author: user) }
  let(:own_investment_in_reviewing_budget) { create(:budget_investment, budget: reviewing_budget, author: user) }
  let(:own_investment_in_selecting_budget) { create(:budget_investment, budget: selecting_budget, author: user) }
  let(:own_investment_in_balloting_budget) { create(:budget_investment, budget: balloting_budget, author: user) }
  let(:ballot_in_accepting_budget) { create(:budget_ballot, budget: accepting_budget) }
  let(:ballot_in_selecting_budget) { create(:budget_ballot, budget: selecting_budget) }
  let(:ballot_in_balloting_budget) { create(:budget_ballot, budget: balloting_budget) }

  let(:current_poll) { create(:poll) }
  let(:expired_poll) { create(:poll, :expired) }
  let(:expired_poll_from_own_geozone) { create(:poll, :expired, geozone_restricted: true, geozones: [geozone]) }
  let(:expired_poll_from_other_geozone) { create(:poll, :expired, geozone_restricted: true, geozones: [create(:geozone)]) }
  let(:poll) { create(:poll, geozone_restricted: false) }
  let(:poll_from_own_geozone) { create(:poll, geozone_restricted: true, geozones: [geozone]) }
  let(:poll_from_other_geozone) { create(:poll, geozone_restricted: true, geozones: [create(:geozone)]) }

  let(:poll_question_from_own_geozone)   { create(:poll_question, poll: poll_from_own_geozone) }
  let(:poll_question_from_other_geozone) { create(:poll_question, poll: poll_from_other_geozone) }
  let(:poll_question_from_all_geozones)  { create(:poll_question, poll: poll) }

  let(:expired_poll_question_from_own_geozone)   { create(:poll_question, poll: expired_poll_from_own_geozone) }
  let(:expired_poll_question_from_other_geozone) { create(:poll_question, poll: expired_poll_from_other_geozone) }
  let(:expired_poll_question_from_all_geozones)  { create(:poll_question, poll: expired_poll) }

  let(:own_proposal_document)          { build(:document, documentable: own_proposal) }
  let(:proposal_document)              { build(:document, documentable: proposal) }
  let(:own_budget_investment_document) { build(:document, documentable: own_investment_in_accepting_budget) }
  let(:budget_investment_document)     { build(:document, documentable: investment_in_accepting_budget) }

  let(:own_proposal_image)          { build(:image, imageable: own_proposal) }
  let(:proposal_image)              { build(:image, imageable: proposal) }
  let(:own_budget_investment_image) { build(:image, imageable: own_investment_in_accepting_budget) }
  let(:budget_investment_image)     { build(:image, imageable: investment_in_accepting_budget) }

  describe "when level 2 verified" do
    let(:own_direct_message) { create(:direct_message, sender: user) }

    before { user.update(residence_verified_at: Time.current, confirmed_phone: "1") }

    describe "Poll" do
      context "Poll::Answer" do
        let(:own_answer) { create(:poll_answer, author: user) }
        let(:other_user_answer) { create(:poll_answer) }
        let(:expired_poll) { create(:poll, :expired) }
        let(:question) { create(:poll_question, :yes_no, poll: expired_poll) }
        let(:expired_poll_answer) { create(:poll_answer, author: user, question: question, answer: "Yes") }

        it { should_not be_able_to(:destroy, own_answer) }
        it { should_not be_able_to(:destroy, other_user_answer) }
        it { should_not be_able_to(:destroy, expired_poll_answer) }
      end
    end
  end
end
