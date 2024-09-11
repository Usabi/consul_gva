require "rails_helper"

describe "Public area translatable records" do
  let(:user) { create(:user, :in_census) }

  before do
    Setting["feature.translation_interface"] = true
    login_as(user)
  end

  context "Globalize javascript interface" do
    scenario "Highlight new locale added" do
      visit new_proposal_path

      select_language("Cast")

      expect_to_have_language_selected "Cast"
    end

    context "Languages in use" do
      scenario "Increase description count after add new language" do
        visit new_proposal_path

        select "Cast", from: :add_language

        expect(page).to have_content "2 languages in use"
      end
    end
  end

  context "Existing records" do
    before { translatable.update(attributes.merge(author: user)) }

    let(:attributes) do
      translatable.translated_attribute_names.product(%i[en es]).to_h do |field, locale|
        [:"#{field}_#{locale}", text_for(field, locale)]
      end
    end

    context "Update a translation" do
      context "With valid data" do
        let(:translatable) { create(:debate) }
        let(:path) { edit_debate_path(translatable) }

        scenario "Changes the existing translation" do
          visit path

          select "Cast", from: :select_language

          fill_in "Debate title", with: "Título corregido"
          fill_in_ckeditor "Initial debate text", with: "Texto corregido"

          click_button "Save changes"

          visit path

          expect(page).to have_field "Debate title", with: "Title in English"

          select_language("Cast")

          expect(page).to have_field "Título del debate", with: "Título corregido"
          expect(page).to have_ckeditor "Texto inicial del debate", with: "Texto corregido"
        end
      end

      context "Update a translation with invalid data" do
        let(:translatable) { create(:proposal) }

        scenario "Show validation errors" do
          visit edit_proposal_path(translatable)
          select "Cast", from: :select_language

          expect(page).to have_field "Proposal title", with: "Título en español"

          fill_in "Proposal title", with: ""
          click_button "Save changes"

          expect(page).to have_css "#error_explanation"

          select "Cast", from: :select_language

          expect(page).to have_field "Proposal title", with: "", class: "is-invalid-input"
        end
      end
    end
  end
end
