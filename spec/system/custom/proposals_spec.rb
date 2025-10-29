require "rails_helper"

describe "Proposals" do
  describe "Proposal index order filters" do
    scenario "Debates are ordered by hot_score" do
      best_proposal = create(:proposal, title: "Best proposal")
      best_proposal.update_column(:hot_score, 10)
      worst_proposal = create(:proposal, title: "Worst proposal")
      worst_proposal.update_column(:hot_score, 2)
      medium_proposal = create(:proposal, title: "Medium proposal")
      medium_proposal.update_column(:hot_score, 5)

      visit proposals_path
      click_link "most active"

      expect(page).to have_css("a.is-active", text: "most active")

      within "#proposals" do
        expect(best_proposal.title).to appear_before(medium_proposal.title)
        expect(medium_proposal.title).to appear_before(worst_proposal.title)
      end

      expect(page).to have_current_path(/order=hot_score/)
      expect(page).to have_current_path(/page=1/)
    end
  end

  context "Summary" do
    scenario "Displays proposals" do
      create(:tag, :category, name: "culture")
      proposal1 = create(:proposal, tag_list: "culture", created_at: 1.day.ago)
      proposal2 = create(:proposal, tag_list: "culture", created_at: 5.days.ago)
      proposal3 = create(:proposal, tag_list: "culture", created_at: 8.days.ago)

      visit summary_proposals_path

      within("#proposals") do
        expect(page).to have_css(".proposal", count: 3)

        expect(page).to have_content(proposal1.title)
        expect(page).to have_content(proposal2.title)
        expect(page).to have_content(proposal3.title)
      end
    end
  end

  # TODO: revisar
  # it_behaves_like "nested documentable",
  #                 "user",
  #                 "proposal",
  #                 "new_proposal_path",
  #                 {},
  #                 "documentable_fill_new_valid_proposal",
  #                 "Create proposal",
  #                 "Proposal created successfully"
  # TODO: revisar
  # it_behaves_like "nested documentable",
  #                 "user",
  #                 "proposal",
  #                 "edit_proposal_path",
  #                 { id: "id" },
  #                 nil,
  #                 "Save changes",
  #                 "Proposal updated successfully"

  scenario "Create and publish", :with_frozen_time do
    author = create(:user)
    login_as(author)

    visit new_proposal_path

    fill_in_new_proposal_title with: "Help refugees"
    fill_in "Proposal summary", with: "In summary, what we want is..."
    fill_in_ckeditor "Proposal text", with: "This is very important because..."
    fill_in "External video URL", with: "https://www.youtube.com/watch?v=yPQfcG-eimk"
    fill_in "Name and surname of the person who makes this proposal", with: "Isabel Garcia"
    fill_in "Tags", with: "Refugees, Solidarity"
    check "I agree to the Privacy Policy and the Terms and conditions of use"

    click_button "Create proposal"

    expect(page).to have_content "Proposal created successfully."
    expect(page).to have_content "Help refugees"
    expect(page).not_to have_content "You can also see more information about improving your campaign"

    click_link "No, I want to publish the proposal"

    expect(page).to have_content "Improve your campaign and get more support"
    click_link "Not now, go to my proposal"

    expect(page).to have_content "Help refugees"
    expect(page).to have_content "In summary, what we want is..."
    expect(page).to have_content "This is very important because..."
    expect(page).to have_content "https://www.youtube.com/watch?v=yPQfcG-eimk"
    expect(page).to have_content author.name
    expect(page).to have_content "Refugees"
    expect(page).to have_content "Solidarity"
    expect(page).to have_content I18n.l(Date.current)
  end

  describe "SDG related list" do
    let(:user) { create(:user) }

    before do
      Setting["feature.sdg"] = true
      Setting["sdg.process.proposals"] = true
    end

    scenario "create proposal with sdg related list" do
      login_as(user)
      visit new_proposal_path
      fill_in_new_proposal_title with: "A title for a proposal related with SDG related content"
      fill_in "Proposal summary", with: "In summary, what we want is..."
      fill_in "Name and surname of the person who makes this proposal", with: "Isabel Garcia"
      click_sdg_goal(1)
      check "I agree to the Privacy Policy and the Terms and conditions of use"

      click_button "Create proposal"

      within(".sdg-goal-tag-list") { expect(page).to have_link "1. No Poverty" }
    end
  end
end
