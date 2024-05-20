require "rails_helper"

describe "Admin legislation questions", :admin do
  let!(:process) { create(:legislation_process, title: "An example legislation process") }

  context "Legislation options" do
    let!(:question) { create(:legislation_question) }

    let(:edit_question_url) do
      edit_admin_legislation_process_question_path(question.process, question)
    end

    let(:field_en) { fields_for(:en).first }
    let(:field_es) { fields_for(:es).first }

    def fields_for(locale)
      within("#nested_question_options") do
        page.all(
          "[data-locale='#{locale}'] [id^='legislation_question_question_option'][id$='value']"
        )
      end
    end

    context "Special translation behaviour" do
      before do
        question.update!(title_en: "Title in English", title_es: "Título en Español")
      end

      scenario "Add translation for question option" do
        visit edit_question_url

        click_on "Add option"

        find("#nested_question_options input").set("Option 1")

        select "Cast", from: :select_language

        find("#nested_question_options input").set("Opción 1")

        click_button "Save changes"
        visit edit_question_url

        expect(page).to have_field(field_en[:id], with: "Option 1")

        select "Cast", from: :select_language

        expect(page).to have_field(field_es[:id], with: "Opción 1")
      end

      scenario "Add new question option after changing active locale" do
        visit edit_question_url

        select "Cast", from: :select_language

        click_on "Add option"

        find("#nested_question_options input").set("Opción 1")

        select "English", from: :select_language

        find("#nested_question_options input").set("Option 1")

        click_button "Save changes"

        visit edit_question_url

        expect(page).to have_field(field_en[:id], with: "Option 1")

        select "Cast", from: :select_language

        expect(page).to have_field(field_es[:id], with: "Opción 1")
      end
    end
  end
end
