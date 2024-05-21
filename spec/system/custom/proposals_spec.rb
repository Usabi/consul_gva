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

      expect(page).to have_selector("a.is-active", text: "most active")

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

end
