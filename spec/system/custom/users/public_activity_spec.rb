require "rails_helper"

describe "Users public activity" do
  describe "Legislation processes tab" do
    before { Setting["process.legislation"] = true }

    scenario "Shows legislation processes where the user has commented" do
      user = create(:user)
      process = create(:legislation_process, :published, title: "Proceso de movilidad")
      question = create(:legislation_question, process: process)
      create(:comment, commentable: question, author: user)

      visit user_path(user, filter: "legislation_processes")

      expect(page).to have_content "Proceso de movilidad"
    end

    scenario "Hides the filter when the user has no activity in legislation processes" do
      user = create(:user)

      visit user_path(user)

      expect(page).not_to have_content "Legislation process"
    end
  end

  describe "Attached documents tab" do
    scenario "Shows documents uploaded by the user" do
      user = create(:user)
      proposal = create(:proposal)
      create(:document, user: user, documentable: proposal, title: "Mi documento adjunto")

      visit user_path(user, filter: "attached_documents")

      expect(page).to have_content "Mi documento adjunto"
    end

    scenario "Shows documents attached to comments and links to the comment" do
      user = create(:user)
      comment = create(:comment, user: user, body: "Comentario con informe")
      create(:document, user: user, documentable: comment, title: "informe-comentario.pdf")

      visit user_path(user, filter: "attached_documents")

      expect(page).to have_content "informe-comentario.pdf"
      expect(page).to have_link "Comentario con informe", href: comment_path(comment)
    end

    scenario "Hides the filter when the user has no uploaded documents" do
      user = create(:user)

      visit user_path(user)

      expect(page).not_to have_content "Attached document"
    end
  end
end
