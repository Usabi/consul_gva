require "rails_helper"

describe "Legislation proposals edition" do
  let(:process) { create(:legislation_process, :in_proposals_phase) }
  let(:author) { create(:user, :level_two) }
  let!(:proposal) { create(:legislation_proposal, process: process, author: author) }

  scenario "Author can edit own proposal without supports" do
    login_as(author)
    visit legislation_process_proposal_path(process, proposal)

    click_link "Edit proposal"
    fill_in "Proposal title", with: "Updated title for the proposal"
    click_button "Save changes"

    expect(page).to have_content "Updated title for the proposal"
  end

  scenario "Author sees that edition is only available while there are no supports" do
    login_as(author)
    note = "Editing is only available while the proposal has no supports"

    visit legislation_process_proposal_path(process, proposal)
    expect(page).to have_content note

    visit edit_legislation_process_proposal_path(process, proposal)
    expect(page).to have_content note
  end

  scenario "Author cannot edit own proposal once supported" do
    create(:vote, votable: proposal)
    login_as(author)

    visit legislation_process_proposal_path(process, proposal)
    expect(page).not_to have_link "Edit proposal"
    expect(page).to have_content "Editing is only available while the proposal has no supports"

    visit edit_legislation_process_proposal_path(process, proposal)
    expect(page).to have_content "Editing is not available: the proposal has already received supports."
    expect(page).to have_current_path legislation_process_proposal_path(process, proposal)
  end

  scenario "Other users do not see the edit link" do
    login_as(create(:user, :level_two))
    visit legislation_process_proposal_path(process, proposal)

    expect(page).not_to have_link "Edit proposal"
    expect(page).not_to have_content "Editing is only available"
  end
end
