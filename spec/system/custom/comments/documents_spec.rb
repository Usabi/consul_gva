require "rails_helper"

describe "Comment documents" do
  let(:user) { create(:user) }
  let(:debate) { create(:debate) }
  let(:pdf_path) { Rails.root.join("spec/fixtures/files/empty.pdf") }

  scenario "user attaches a document when commenting" do
    login_as(user)
    visit debate_path(debate)

    fill_in "Leave your comment", with: "Mirad el informe adjunto"
    expect(page).to have_css "details.comment-attachment:not([open])", match: :first
    first("details.comment-attachment summary", text: "Attach document").click
    attach_file "comment[attachment]", pdf_path, match: :first
    click_button "Publish comment"

    within "#comments" do
      expect(page).to have_content "Mirad el informe adjunto"
      expect(page).to have_css("a .document-title", text: "empty.pdf")
    end
    expect(Comment.last.documents.count).to eq(1)
    expect(Comment.last.documents.first.user).to eq(user)
  end

  scenario "shows the selected file name and allows removing it" do
    login_as(user)
    visit debate_path(debate)

    first("details.comment-attachment summary", text: "Attach document").click
    within first("details.comment-attachment") do
      expect(page).to have_css "label.comment-attachment-button", text: "Choose file"
      expect(page).to have_css ".comment-attachment-name", text: "No file selected"
      expect(page).not_to have_button "Remove file"

      attach_file "comment[attachment]", pdf_path, visible: :all
      expect(page).to have_css ".comment-attachment-name", text: "empty.pdf"

      click_button "Remove file"
      expect(page).to have_css ".comment-attachment-name", text: "No file selected"
      expect(page).not_to have_button "Remove file"
    end
  end

  scenario "comment without document still works" do
    login_as(user)
    visit debate_path(debate)

    fill_in "Leave your comment", with: "Sin adjunto"
    click_button "Publish comment"

    within "#comments" do
      expect(page).to have_content "Sin adjunto"
    end
    expect(Comment.last.documents).to be_empty
  end

  scenario "rejects documents with a not accepted content type" do
    login_as(user)
    visit debate_path(debate)

    fill_in "Leave your comment", with: "Imagen no permitida"
    first("details.comment-attachment summary", text: "Attach document").click
    attach_file "comment[attachment]", Rails.root.join("spec/fixtures/files/clippy.jpg"), match: :first
    click_button "Publish comment"

    expect(page).to have_content "does not match any of accepted content types"
    expect(Comment.where(commentable: debate).count).to eq(0)
  end

  scenario "document appears in the user activity comments tab" do
    comment = create(:comment, commentable: debate, user: user, body: "Con documento")
    create(:document, documentable: comment, user: user, title: "informe.pdf")

    visit user_path(user, filter: "comments")

    within "#comment_#{comment.id}" do
      expect(page).to have_content "Con documento"
      expect(page).to have_css("a .document-title", text: "informe.pdf")
    end
  end

  describe "moderation by administrators" do
    let!(:comment) { create(:comment, commentable: debate, user: user, body: "Comentario con adjunto") }
    let!(:document) { create(:document, documentable: comment, user: user, title: "impropio.pdf") }

    scenario "administrator hides an improper document and the comment stays" do
      login_as(create(:administrator).user)
      visit debate_path(debate)

      within "#document_#{document.id}" do
        accept_confirm { click_button "Hide document" }
      end

      expect(page).to have_content "Comentario con adjunto"
      within "#document_#{document.id}" do
        expect(page).to have_content "Hidden"
        expect(page).to have_button "Restore document"
        expect(page).not_to have_button "Hide document"
      end
      expect(document.reload).to be_hidden

      logout
      visit debate_path(debate)

      expect(page).to have_content "Comentario con adjunto"
      expect(page).not_to have_css "a .document-title", text: "impropio.pdf"
    end

    scenario "hidden document is not shown to regular users nor in activity" do
      document.hide

      visit debate_path(debate)
      expect(page).to have_content "Comentario con adjunto"
      expect(page).not_to have_css "a .document-title", text: "impropio.pdf"

      visit user_path(user, filter: "comments")
      expect(page).to have_content "Comentario con adjunto"
      expect(page).not_to have_css "a .document-title", text: "impropio.pdf"
    end

    scenario "administrator sees hidden document and can restore it" do
      document.hide
      login_as(create(:administrator).user)
      visit debate_path(debate)

      within "#document_#{document.id}" do
        click_button "Restore document"
      end

      expect(page).to have_css "a .document-title", text: "impropio.pdf"
      expect(document.reload).not_to be_hidden
    end

    scenario "regular user cannot see hide button" do
      login_as(create(:user))
      visit debate_path(debate)

      expect(page).to have_css "a .document-title", text: "impropio.pdf"
      expect(page).not_to have_button "Hide document"
    end
  end
end
