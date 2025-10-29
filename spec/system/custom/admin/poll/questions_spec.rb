require "rails_helper"

describe "Admin poll questions", :admin do
  context "Poll select box" do
    scenario "translates the poll name in options" do
      poll = create(:poll, :future, name_en: "Name in English", name_es: "Nombre en Español")
      proposal = create(:proposal)

      visit admin_proposal_path(proposal)
      click_link "Add this proposal to a poll to be voted"

      expect(page).to have_select("poll_question_poll_id", options: ["Select Poll", poll.name_en])

      select_language("Cast")

      expect(page).to have_select("poll_question_poll_id",
                                  options: ["Seleccionar votación", poll.name_es])
    end

    scenario "uses fallback if name is not translated to current locale",
             if: Globalize.fallbacks(:fr).reject { |locale| locale.match(/fr/) }.first == :es do
      poll = create(:poll, :future, name_en: "Name in English", name_es: "Nombre en Español")
      proposal = create(:proposal)

      visit admin_proposal_path(proposal)
      click_link "Add this proposal to a poll to be voted"

      expect(page).to have_select("poll_question_poll_id", options: ["Select Poll", poll.name_en])

      select_language("Français")

      expect(page).to have_select("poll_question_poll_id",
                                  options: ["Sélectionner un vote", poll.name_es])
    end
  end

  scenario "Successful proposals tab not available in custom" do
    create(:poll, :future, name: "Proposals")
    create(:proposal, :successful)

    visit admin_proposals_path

    # In custom, the proposals_tabs helper (app/helpers/custom/proposals_helper.rb)
    # only includes "proposals" and "help_text" tabs, not "successful_proposals"
    expect(page).not_to have_link "Successful proposals"
  end
end
