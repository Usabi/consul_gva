require "rails_helper"

describe Dashboard::PollsController do
  let(:author) { create(:user, last_sign_in_at: Time.current) }
  let(:proposal) { create(:proposal, :draft, author: author) }
  let(:other_proposal) { create(:proposal, :draft) }
  let!(:own_poll) { create(:poll, related: proposal, name: "Own poll") }
  let!(:foreign_poll) { create(:poll, related: other_proposal, name: "Foreign poll") }

  before { sign_in(author) }

  describe "GET edit" do
    it "finds a poll of the proposal" do
      get :edit, params: { proposal_id: proposal.to_param, id: own_poll.id }

      expect(response).to be_successful
    end

    it "does not find a poll of another proposal" do
      expect do
        get :edit, params: { proposal_id: proposal.to_param, id: foreign_poll.id }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "does not find a poll unrelated to any proposal" do
      admin_poll = create(:poll, name: "Admin poll")

      expect do
        get :edit, params: { proposal_id: proposal.to_param, id: admin_poll.id }
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "PATCH update" do
    it "updates a poll of the proposal" do
      patch :update, params: { proposal_id: proposal.to_param,
                               id: own_poll.id,
                               poll: { name: "Updated name" }}

      expect(own_poll.reload.name).to eq "Updated name"
    end

    it "does not update a poll of another proposal" do
      expect do
        patch :update, params: { proposal_id: proposal.to_param,
                                 id: foreign_poll.id,
                                 poll: { name: "Hijacked" }}
      end.to raise_error(ActiveRecord::RecordNotFound)

      expect(foreign_poll.reload.name).to eq "Foreign poll"
    end
  end

  describe "DELETE destroy" do
    it "destroys a poll of the proposal" do
      expect do
        delete :destroy, params: { proposal_id: proposal.to_param, id: own_poll.id }
      end.to change { Poll.count }.by(-1)
    end

    it "does not destroy a poll of another proposal" do
      expect do
        delete :destroy, params: { proposal_id: proposal.to_param, id: foreign_poll.id }
      end.to raise_error(ActiveRecord::RecordNotFound)

      expect(Poll.exists?(foreign_poll.id)).to be true
    end
  end

  describe "POST create" do
    it "relates the new poll to the proposal" do
      expect do
        post :create, params: { proposal_id: proposal.to_param,
                                poll: { name: "New poll",
                                        starts_at: 2.months.from_now.to_date,
                                        ends_at: 3.months.from_now.to_date }}
      end.to change { Poll.count }.by(1)

      expect(Poll.last.related).to eq proposal
      expect(Poll.last.author).to eq author
    end
  end

  describe "nested question attributes" do
    it "does not let an author move a question to another proposal" do
      question = create(:poll_question, poll: own_poll, proposal: proposal)

      patch :update, params: { proposal_id: proposal.to_param,
                               id: own_poll.id,
                               poll: { questions_attributes: {
                                 "0" => { id: question.id, proposal_id: other_proposal.id }
                               }}}

      expect(question.reload.proposal).to eq proposal
    end

    it "does not let an author move an option to a question of another poll" do
      question = create(:poll_question, poll: own_poll, proposal: proposal)
      option = create(:poll_question_option, question: question)
      foreign_question = create(:poll_question, poll: foreign_poll, proposal: other_proposal)

      patch :update, params: { proposal_id: proposal.to_param,
                               id: own_poll.id,
                               poll: { questions_attributes: { "0" => {
                                 id: question.id,
                                 question_options_attributes: {
                                   "0" => { id: option.id, question_id: foreign_question.id }
                                 }
                               }}}}

      expect(option.reload.question).to eq question
    end
  end
end
