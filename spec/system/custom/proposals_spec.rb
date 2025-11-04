require "rails_helper"

describe "Proposals" do
  describe "Social share buttons" do
    context "On desktop browsers" do
      scenario "Shows links to share on facebook and twitter" do
        visit proposal_path(create(:proposal))

        within(".social-share-button") do
          expect(page.all("a").count).to be(4)
          expect(page).to have_link "Share to Facebook"
          expect(page).to have_link "Share to Twitter"
          expect(page).to have_link "Share to WhatsApp"
          expect(page).to have_link "Share to Linkedin"
        end
      end
    end

    context "On small devices", :small_window do
      scenario "Shows links to share on telegram and whatsapp too" do
        visit proposal_path(create(:proposal))

        within(".social-share-button") do
          expect(page.all("a").count).to be(5)
          expect(page).to have_link "Share to Facebook"
          expect(page).to have_link "Share to Twitter"
          expect(page).to have_link "Share to Telegram"
          expect(page).to have_link "Share to WhatsApp"
          expect(page).to have_link "Share to Linkedin"
        end
      end
    end
  end

  scenario "Create with invisible_captcha honeypot field", :no_js do
    author = create(:user)
    login_as(author)

    visit new_proposal_path
    fill_in "Proposal title", with: "I am a bot"
    fill_in "If you are human, ignore this field", with: "This is the honeypot field"
    fill_in "Proposal summary", with: "This is the summary"
    fill_in "Proposal text", with: "This is the description"
    fill_in "Name and surname of the person who makes this proposal", with: "Some other robot"
    check "I agree to the Privacy Policy and the Terms and conditions of use"

    click_button "Create proposal"

    expect(page.status_code).to eq(200)
    expect(page.html).to be_empty
    expect(page).to have_current_path(proposals_path)
  end

  scenario "Create proposal too fast" do
    allow(InvisibleCaptcha).to receive(:timestamp_threshold).and_return(Float::INFINITY)

    author = create(:user)
    login_as(author)

    visit new_proposal_path
    fill_in_new_proposal_title with: "I am a bot"
    fill_in "Proposal summary", with: "This is the summary"
    fill_in_ckeditor "Proposal text", with: "This is the description"
    fill_in "Name and surname of the person who makes this proposal", with: "Some other robot"
    check "I agree to the Privacy Policy and the Terms and conditions of use"

    click_button "Create proposal"

    expect(page).to have_content "Sorry, that was too quick! Please resubmit"

    expect(page).to have_current_path(new_proposal_path)
  end

  scenario "JS injection is prevented but safe html is respected", :no_js do
    author = create(:user)
    login_as(author)

    visit new_proposal_path
    fill_in "Proposal title", with: "Testing an attack"
    fill_in "Proposal summary", with: "In summary, what we want is..."
    fill_in "Proposal text", with: "<p>This is <script>alert('an attack');</script></p>"
    fill_in "Name and surname of the person who makes this proposal", with: "Isabel Garcia"
    check "I agree to the Privacy Policy and the Terms and conditions of use"

    click_button "Create proposal"

    expect(page).to have_content "Proposal created successfully."
    click_link "No, I want to publish the proposal"
    click_link "Not now, go to my proposal"

    expect(page).to have_content "Testing an attack"
    expect(page.html).to include "<p>This is alert('an attack');</p>"
    expect(page.html).not_to include "<script>alert('an attack');</script>"
    expect(page.html).not_to include "&lt;p&gt;This is"
  end

  scenario "Autolinking is applied to description" do
    author = create(:user)
    login_as(author)

    visit new_proposal_path
    fill_in_new_proposal_title with: "Testing auto link"
    fill_in "Proposal summary", with: "In summary, what we want is..."
    fill_in_ckeditor "Proposal text", with: "This is a link www.example.org"
    fill_in "Name and surname of the person who makes this proposal", with: "Isabel Garcia"
    check "I agree to the Privacy Policy and the Terms and conditions of use"

    click_button "Create proposal"

    expect(page).to have_content "Proposal created successfully."
    click_link "No, I want to publish the proposal"
    click_link "Not now, go to my proposal"

    expect(page).to have_content "Testing auto link"
    expect(page).to have_link("www.example.org", href: "http://www.example.org")
  end

  scenario "JS injection is prevented but autolinking is respected", :no_js do
    author = create(:user)
    js_injection_string = "<script>alert('hey')</script> " \
                          "<a href=\"javascript:alert('surprise!')\">click me<a/> " \
                          "http://example.org"
    login_as(author)

    visit new_proposal_path
    fill_in "Proposal title", with: "Testing auto link"
    fill_in "Proposal summary", with: "In summary, what we want is..."
    fill_in "Proposal text", with: js_injection_string
    fill_in "Name and surname of the person who makes this proposal", with: "Isabel Garcia"
    check "I agree to the Privacy Policy and the Terms and conditions of use"

    click_button "Create proposal"

    expect(page).to have_content "Proposal created successfully."
    click_link "No, I want to publish the proposal"
    click_link "Not now, go to my proposal"

    expect(page).to have_content "Testing auto link"
    expect(page).to have_link("http://example.org", href: "http://example.org")
    expect(page).not_to have_link("click me")
    expect(page.html).not_to include "<script>alert('hey')</script>"

    click_link "Dashboard"

    within "#side_menu" do
      click_link "Edit my proposal"
    end

    click_link "Edit proposal"

    expect(page).to have_field "Proposal title", with: "Testing auto link"
    expect(page).not_to have_link("click me")
    expect(page.html).not_to include "<script>alert('hey')</script>"
  end

  context "Geozones" do
    scenario "When there are not gezones defined it does not show the geozone link" do
      visit proposal_path(create(:proposal))

      expect(page).not_to have_css "#geozone"
      expect(page).not_to have_link "All city"
    end

    scenario "Default whole city" do
      create(:geozone)
      author = create(:user)
      login_as(author)

      visit new_proposal_path
      fill_in_proposal

      click_button "Create proposal"

      expect(page).to have_content "Proposal created successfully."
      click_link "No, I want to publish the proposal"
      click_link "Not now, go to my proposal"

      within "#geozone" do
        expect(page).to have_content "All city"
      end
    end

    scenario "Specific geozone" do
      create(:geozone, name: "California")
      create(:geozone, name: "New York")
      login_as(create(:user))

      visit new_proposal_path

      fill_in_new_proposal_title with: "Help refugees"
      fill_in "Proposal summary", with: "In summary, what we want is..."
      fill_in_ckeditor "Proposal text", with: "This is very important because..."
      fill_in "External video URL", with: "https://www.youtube.com/watch?v=yPQfcG-eimk"
      fill_in "Name and surname of the person who makes this proposal", with: "Isabel Garcia"
      check "I agree to the Privacy Policy and the Terms and conditions of use"

      select("California", from: "proposal_geozone_id")
      click_button "Create proposal"

      expect(page).to have_content "Proposal created successfully."
      click_link "No, I want to publish the proposal"
      click_link "Not now, go to my proposal"

      within "#geozone" do
        expect(page).to have_content "California"
      end
    end
  end

  context "Withdrawn proposals" do
    scenario "Withdraw" do
      original_proposal = create(:proposal, title: "Original proposal")
      # Admin already marked this proposal as duplicated
      proposal = create(:proposal, duplicated_of_proposal_id: original_proposal.id)
      login_as(proposal.author)

      visit user_path(proposal.author)
      within("#proposal_#{proposal.id}") do
        click_link "Dashboard"
      end

      within "#side_menu" do
        click_link "Edit my proposal"
      end

      click_link "Withdraw proposal"

      expect(page).to have_current_path(retire_form_proposal_path(proposal))

      select "Duplicated", from: "proposal_retired_reason"
      click_button "Withdraw proposal"

      expect(page).to have_content "The proposal has been withdrawn"

      visit proposal_path(proposal)

      expect(page).to have_content proposal.title
      expect(page).to have_content "Proposal withdrawn by the author"
      expect(page).to have_content "Duplicated"
      expect(page).to have_content original_proposal.title
    end

    scenario "Fields are mandatory" do
      proposal = create(:proposal)
      login_as(proposal.author)

      visit retire_form_proposal_path(proposal)

      click_button "Withdraw proposal"

      expect(page).not_to have_content "The proposal has been withdrawn"
      expect(page).to have_content "can't be blank"
    end
  end

  scenario "Update should be posible for the author of an editable proposal" do
    proposal = create(:proposal)
    login_as(proposal.author)

    visit edit_proposal_path(proposal)
    expect(page).to have_current_path(edit_proposal_path(proposal))

    fill_in "Proposal title", with: "End child poverty"
    fill_in "Proposal summary", with: "Basically..."
    fill_in_ckeditor "Proposal text", with: "Let's do something to end child poverty"
    fill_in "Name and surname of the person who makes this proposal", with: "Isabel Garcia"

    click_button "Save changes"

    expect(page).to have_content "Proposal updated successfully."
    expect(page).to have_content "Basically..."
    expect(page).to have_content "End child poverty"
    expect(page).to have_content "Let's do something to end child poverty"
  end

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

  scenario "Responsible name is stored for anonymous users" do
    author = create(:user)
    login_as(author)

    visit new_proposal_path
    fill_in_new_proposal_title with: "Help refugees"
    fill_in "Proposal summary", with: "In summary, what we want is..."
    fill_in_ckeditor "Proposal text", with: "This is very important because..."
    fill_in "Name and surname of the person who makes this proposal", with: "Isabel Garcia"
    check "I agree to the Privacy Policy and the Terms and conditions of use"

    click_button "Create proposal"

    expect(page).to have_content "Proposal created successfully."
    click_link "No, I want to publish the proposal"
    click_link "Not now, go to my proposal"

    click_link "Dashboard"
    click_link "Edit my proposal"

    click_link "Edit proposal"

    expect(page).to have_field "Name and surname of the person who makes this proposal", with: "Isabel Garcia"
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

describe "Successful proposals" do
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
