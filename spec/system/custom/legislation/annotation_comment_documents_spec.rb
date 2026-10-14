require "rails_helper"

describe "Draft version annotation comment documents" do
  let(:user) { create(:user) }
  let(:draft_version) { create(:legislation_draft_version, :published) }
  let(:pdf_path) { Rails.root.join("spec/fixtures/files/empty.pdf") }
  let!(:annotation) do
    create(:legislation_annotation,
           draft_version: draft_version,
           text: "my annotation",
           ranges: [{ "start" => "/p[1]", "startOffset" => 6, "end" => "/p[1]", "endOffset" => 11 }])
  end

  scenario "user attaches a document when commenting an annotation" do
    login_as(user)
    visit legislation_process_draft_version_path(draft_version.process, draft_version)

    first(:css, ".annotator-hl").click
    click_link "Publish Comment"
    fill_in "comment[body]", with: "Comentario con adjunto"
    first("details.comment-attachment summary", text: "Attach document").click
    attach_file "comment[attachment]", pdf_path, visible: :all
    click_button "Publish comment"

    expect(page).to have_content "Comentario con adjunto"
    expect(page).to have_css("a .document-title", text: "empty.pdf")
    expect(annotation.comments.find_by(body: "Comentario con adjunto").documents.count).to eq 1
  end

  scenario "user attaches a document when creating a new annotation" do
    annotation.destroy!
    login_as(user)
    visit legislation_process_draft_version_path(draft_version.process, draft_version)

    page.find(:css, ".legislation-annotatable").double_click
    page.find(:css, ".annotator-adder button").click
    fill_in "legislation_annotation_text", with: "Anotación con adjunto"
    within("#comments-box") do
      first("details.comment-attachment summary", text: "Attach document").click
      attach_file "legislation_annotation[attachment]", pdf_path, visible: :all
    end
    page.click_button "Publish Comment"

    expect(page).to have_css(".annotator-hl")
    comment = Legislation::Annotation.last.comments.first
    expect(comment.body).to eq "Anotación con adjunto"
    expect(comment.documents.first.title).to eq "empty.pdf"
    expect(page).to have_css("a .document-title", text: "empty.pdf")
  end

  scenario "attachment picker of the new annotation form is styled like the comment one" do
    annotation.destroy!
    login_as(user)
    visit legislation_process_draft_version_path(draft_version.process, draft_version)

    page.find(:css, ".legislation-annotatable").double_click
    page.find(:css, ".annotator-adder button").click

    within("#comments-box") do
      summary = first("details.comment-attachment summary", text: "Attach document")
      summary.click

      selector = "#comments-box details.comment-attachment summary"
      weight = evaluate_script("window.getComputedStyle(document.querySelector('#{selector}')).fontWeight")
      expect(weight.to_i).to be >= 700
      expect(page).to have_css ".comment-attachment-picker", style: { display: "flex" }
    end
  end

  context "with a document over the size limit" do
    let(:big_pdf) do
      file = Tempfile.new(["grande", ".pdf"])
      file.write("%PDF-1.4\n" + ("a" * (Comment.max_file_size.megabytes + 1024)))
      file.flush
      file
    end

    scenario "shows an error and does not create the comment on an existing annotation" do
      login_as(user)
      visit legislation_process_draft_version_path(draft_version.process, draft_version)

      first(:css, ".annotator-hl").click
      click_link "Publish Comment"
      fill_in "comment[body]", with: "Adjunto demasiado grande"
      first("details.comment-attachment summary", text: "Attach document").click
      attach_file "comment[attachment]", big_pdf.path, visible: :all
      click_button "Publish comment"

      expect(page).to have_css "#comments-box .callout.alert", text: /too heavy|size|MB/i
      expect(annotation.comments.where(body: "Adjunto demasiado grande")).to be_empty
    end

    scenario "shows an error and does not create a new annotation" do
      annotation.destroy!
      login_as(user)
      visit legislation_process_draft_version_path(draft_version.process, draft_version)

      page.find(:css, ".legislation-annotatable").double_click
      page.find(:css, ".annotator-adder button").click
      fill_in "legislation_annotation_text", with: "Anotación con adjunto grande"
      within("#comments-box") do
        first("details.comment-attachment summary", text: "Attach document").click
        attach_file "legislation_annotation[attachment]", big_pdf.path, visible: :all
      end
      page.click_button "Publish Comment"

      expect(page).to have_css "#comments-box small.error", text: /too heavy|size|MB/i
      expect(Legislation::Annotation.count).to eq 0
    end
  end

  scenario "user cancels the comment form of an existing annotation" do
    login_as(user)
    visit legislation_process_draft_version_path(draft_version.process, draft_version)

    first(:css, ".annotator-hl").click
    click_link "Publish Comment"
    fill_in "comment[body]", with: "No lo publico"
    click_link "Cancel"

    expect(page).not_to have_css "#comments-box textarea", visible: :visible
    expect(page).to have_link "Publish Comment"

    click_link "Publish Comment"
    expect(page).to have_css "#comments-box textarea", visible: :visible
  end

  scenario "comments box with the attachment picker open does not overlap the footer" do
    draft_version.update!(body: "# Borrador\n\nArtículo 1. Texto corto.\n\nArtículo 2. Otro párrafo.")
    login_as(user)
    visit legislation_process_draft_version_path(draft_version.process, draft_version)

    first(:css, ".annotator-hl").click
    click_link "Publish Comment"
    first("details.comment-attachment summary", text: "Attach document").click
    expect(page).to have_css "#comments-box .comment-attachment-picker"

    overlap = evaluate_script(<<~JS)
      (function() {
        var box = document.querySelector("#comments-box .comment-box").getBoundingClientRect();
        var footer = document.querySelector("footer").getBoundingClientRect();
        return box.bottom - footer.top;
      })()
    JS

    expect(overlap).to be <= 0
  end

  scenario "document shows in the annotation page and the process summary" do
    draft_version.process.update!(end_date: Date.current - 1.day)
    comment = create(:comment, commentable: annotation, user: user)
    create(:document, documentable: comment, user: user, title: "informe.pdf")

    visit legislation_process_draft_version_annotation_path(draft_version.process, draft_version, annotation)
    expect(page).to have_css("a .document-title", text: "informe.pdf")

    visit summary_legislation_process_path(draft_version.process, section: "allegations")
    expect(page).to have_css("a .document-title", text: "informe.pdf")
  end
end
