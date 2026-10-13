require "rails_helper"

describe "Moderation of hidden documents" do
  let(:administrator) { create(:administrator).user }
  let(:comment) { create(:comment, body: "Comentario moderado") }
  let!(:hidden_document) do
    create(:document, documentable: comment, user: comment.user, title: "oculto.pdf")
  end

  before do
    create(:document, documentable: comment, user: comment.user, title: "visible.pdf")
    hidden_document.hide
  end

  scenario "hidden documents are listed in the moderation panel" do
    login_as(administrator)
    visit moderation_root_path

    within("#moderation_menu") { click_link "Hidden documents" }

    expect(page).to have_content "oculto.pdf"
    expect(page).to have_content "Comentario moderado"
    expect(page).not_to have_content "visible.pdf"
  end

  scenario "moderator restores a hidden document from the panel" do
    login_as(create(:moderator).user)
    visit moderation_documents_path

    within "#document_#{hidden_document.id}" do
      click_button "Restore document"
    end

    expect(page).not_to have_content "oculto.pdf"
    expect(hidden_document.reload).not_to be_hidden
  end

  scenario "administrator restores a hidden document from the panel" do
    login_as(administrator)
    visit moderation_documents_path

    within "#document_#{hidden_document.id}" do
      click_button "Restore document"
    end

    expect(page).not_to have_content "oculto.pdf"
    expect(hidden_document.reload).not_to be_hidden
  end

  scenario "regular users cannot access the list" do
    login_as(create(:user))
    visit moderation_documents_path

    expect(page).to have_current_path(root_path)
  end
end
