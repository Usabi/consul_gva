require "rails_helper"

describe Legislation::ProposalsController do
  let(:legislation_process) { create(:legislation_process, :in_proposals_phase) }
  let(:author) { create(:user, :level_two) }
  let!(:proposal) { create(:legislation_proposal, process: legislation_process, author: author) }
  let(:new_title) { "Title changed after supports" }

  before { allow(InvisibleCaptcha).to receive(:timestamp_enabled).and_return(false) }

  def update_proposal
    patch :update, params: { process_id: legislation_process.id,
                             id: proposal.id,
                             legislation_proposal: { title: new_title }}
  end

  context "when the form was opened before the proposal got supports" do
    before { sign_in author }

    it "does not update the proposal once it has supports" do
      create(:vote, votable: proposal)

      update_proposal

      expect(proposal.reload.title).not_to eq new_title
      expect(response).to have_http_status(:redirect)
    end

    it "does not show the edit form once it has supports" do
      create(:vote, votable: proposal)

      get :edit, params: { process_id: legislation_process.id, id: proposal.id }

      expect(response).not_to have_http_status(:ok)
    end
  end

  context "when the proposals phase is closed" do
    before do
      sign_in author
      legislation_process.update!(proposals_phase_end_date: Date.yesterday)
    end

    it "does not update the proposal" do
      update_proposal

      expect(proposal.reload.title).not_to eq new_title
    end

    it "does not show the edit form" do
      get :edit, params: { process_id: legislation_process.id, id: proposal.id }

      expect(response).not_to have_http_status(:ok)
    end
  end

  context "when the process is closed" do
    before do
      sign_in author
      legislation_process.update_columns(end_date: Date.yesterday)
    end

    it "does not update the proposal" do
      update_proposal

      expect(proposal.reload.title).not_to eq new_title
    end

    it "does not show the edit form" do
      get :edit, params: { process_id: legislation_process.id, id: proposal.id }

      expect(response).not_to have_http_status(:ok)
    end
  end

  context "when a legislator or administrator tries to edit" do
    [:legislator, :administrator].each do |role|
      it "#{role} cannot update a supported proposal" do
        create(:vote, votable: proposal)
        sign_in create(role).user

        update_proposal

        expect(proposal.reload.title).not_to eq new_title
      end

      it "#{role} cannot update when the phase is closed" do
        legislation_process.update!(proposals_phase_end_date: Date.yesterday)
        sign_in create(role).user

        update_proposal

        expect(proposal.reload.title).not_to eq new_title
      end
    end
  end

  it "author can update a proposal without supports in an open phase" do
    sign_in author

    update_proposal

    expect(proposal.reload.title).to eq new_title
  end

  describe "denied edition message" do
    before { sign_in author }

    it "explains that the proposal already has supports" do
      create(:vote, votable: proposal)

      get :edit, params: { process_id: legislation_process.id, id: proposal.id }

      expect(response).to redirect_to(legislation_process_proposal_path(legislation_process, proposal))
      expect(flash[:alert]).to eq I18n.t("legislation.proposals.edit_denied.supports")
    end

    it "explains that the proposals phase is closed" do
      legislation_process.update!(proposals_phase_end_date: Date.yesterday)

      patch :update, params: { process_id: legislation_process.id,
                               id: proposal.id,
                               legislation_proposal: { title: new_title }}

      expect(response).to redirect_to(legislation_process_proposal_path(legislation_process, proposal))
      expect(flash[:alert]).to eq I18n.t("legislation.proposals.edit_denied.closed")
    end

    it "explains that the process is closed" do
      legislation_process.update_columns(end_date: Date.yesterday)

      get :edit, params: { process_id: legislation_process.id, id: proposal.id }

      expect(response).to redirect_to(legislation_process_proposal_path(legislation_process, proposal))
      expect(flash[:alert]).to eq I18n.t("legislation.proposals.edit_denied.process_closed")
    end
  end
end
