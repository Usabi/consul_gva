require "rails_helper"

describe "Home" do
  describe "For signed in users" do
    context "Recommended" do
      before do
        proposal = create(:proposal, tag_list: "Sport")
        user = create(:user, followables: [proposal])
        login_as(user)
      end

      scenario "Does not display recommended section even when feature flag recommended is active" do
        create(:debate, tag_list: "Sport")

        visit root_path

        expect(page).not_to have_content "Recommendations that may interest you"
      end

      scenario "Does not display recommended section when feature flag recommended is not active" do
        create(:debate, tag_list: "Sport")
        Setting["feature.user.recommendations"] = false

        visit root_path

        expect(page).not_to have_content "Recommendations that may interest you"
      end

      scenario "Does not display debates in recommended section" do
        debate = create(:debate, tag_list: "Sport")

        visit root_path

        expect(page).not_to have_css "#section_recommended"
        expect(page).not_to have_link("All recommended debates", href: debates_path(order: "recommendations"))
      end

      scenario "Does not display all recommended debates link" do
        create(:debate, tag_list: "Sport")

        visit root_path

        expect(page).not_to have_link("All recommended debates", href: debates_path(order: "recommendations"))
      end

      scenario "Does not display proposal in recommended section" do
        proposal = create(:proposal, tag_list: "Sport")

        visit root_path

        expect(page).not_to have_css "#section_recommended"
        expect(page).not_to have_link("All recommended proposals", href: proposals_path(order: "recommendations"))
      end

      scenario "Does not display all recommended proposals link" do
        create(:proposal, tag_list: "Sport")

        visit root_path

        expect(page).not_to have_link("All recommended proposals", href: proposals_path(order: "recommendations"))
      end

      scenario "Does not display orbit carrousel" do
        create_list(:debate, 3, tag_list: "Sport")

        visit root_path

        expect(page).not_to have_css "li[data-slide='0']"
        expect(page).not_to have_css "li[data-slide='1']"
        expect(page).not_to have_css "li[data-slide='2']"
      end

      scenario "Does not display carousel for clicking" do
        debate = create(:debate, tag_list: "Sport")

        visit root_path

        expect(page).not_to have_css "#section_recommended"
      end

      scenario "Does not display recommended section when there are not debates and proposals" do
        visit root_path
        expect(page).not_to have_content "Recommendations that may interest you"
      end
    end
  end
end
