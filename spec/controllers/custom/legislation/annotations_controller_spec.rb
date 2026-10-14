require "rails_helper"

describe Legislation::AnnotationsController do
  let(:user) { create(:user) }
  let(:legislation_process) { create(:legislation_process, allegations_start_date: 1.day.ago) }
  let(:draft_version) { create(:legislation_draft_version, :published, process: legislation_process) }
  let!(:annotation) { create(:legislation_annotation, draft_version: draft_version) }
  let(:pdf) { fixture_file_upload("empty.pdf", "application/pdf") }

  before { sign_in user }

  def post_comment(comment_params)
    post :new_comment, params: {
      process_id: legislation_process.id,
      draft_version_id: draft_version.id,
      annotation_id: annotation.id,
      comment: comment_params
    }, format: :js
  end

  describe "POST new_comment" do
    it "attaches the uploaded document to the comment" do
      expect do
        post_comment(body: "Ver informe", attachment: pdf)
      end.to change { annotation.comments.count }.by(1)

      comment = annotation.comments.last
      expect(comment.documents.count).to eq 1
      expect(comment.documents.first.title).to eq "empty.pdf"
      expect(comment.documents.first.user).to eq user
    end

    it "keeps working without a document" do
      expect { post_comment(body: "Sin adjunto") }.to change { annotation.comments.count }.by(1)
      expect(annotation.comments.last.documents).to be_empty
    end

    it "does not create the comment when the document is not valid" do
      file = Tempfile.new(["virus", ".exe"])
      exe = Rack::Test::UploadedFile.new(file.path, "application/x-msdownload")

      expect do
        post_comment(body: "Mal adjunto", attachment: exe)
      end.not_to change { annotation.comments.count }
    end
  end

  describe "oversized documents" do
    let(:big) do
      file = Tempfile.new(["big", ".pdf"])
      file.write("%PDF-1.4\n" + ("a" * (Comment.max_file_size.megabytes + 10)))
      file.flush
      Rack::Test::UploadedFile.new(file.path, "application/pdf")
    end

    it "does not create the comment on an existing annotation" do
      expect do
        post_comment(body: "Muy grande", attachment: big)
      end.not_to change { annotation.comments.count }
    end
  end

  describe "oversized documents on create" do
    it "returns the error messages as json" do
      file = Tempfile.new(["big", ".pdf"])
      file.write("%PDF-1.4\n" + ("a" * (Comment.max_file_size.megabytes + 10)))
      file.flush
      big = Rack::Test::UploadedFile.new(file.path, "application/pdf")

      post :create, params: {
        process_id: legislation_process.id,
        draft_version_id: draft_version.id,
        legislation_annotation: { quote: "x",
                                  text: "y",
                                  attachment: big,
                                  ranges: [{ start: "/p[1]", startOffset: 0, end: "/p[1]", endOffset: 3 }] }
      }, format: :json

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body.first).to match(/MB/)
    end
  end

  describe "POST create" do
    let(:ranges) { [{ start: "/p[1]", startOffset: 0, end: "/p[1]", endOffset: 5 }] }

    def post_annotation(attachment: nil, ranges: self.ranges)
      post :create, params: {
        process_id: legislation_process.id,
        draft_version_id: draft_version.id,
        legislation_annotation: { quote: "texto",
                                  text: "Primer comentario",
                                  ranges: ranges,
                                  attachment: attachment }.compact
      }, format: :json
    end

    it "attaches the document to the first comment of a new annotation" do
      expect { post_annotation(attachment: pdf) }.to change { Legislation::Annotation.count }.by(1)

      comment = Legislation::Annotation.last.comments.first
      expect(comment.body).to eq "Primer comentario"
      expect(comment.documents.count).to eq 1
      expect(comment.documents.first.user).to eq user
    end

    it "attaches the document when commenting an existing range" do
      range = annotation.ranges.first
      existing_ranges = [{ start: range["start"],
                           startOffset: range["startOffset"],
                           end: range["end"],
                           endOffset: range["endOffset"] }]

      expect { post_annotation(attachment: pdf, ranges: existing_ranges) }
        .to change { annotation.comments.count }.by(1)

      expect(annotation.comments.order(:id).last.documents.count).to eq 1
    end

    it "does not create the annotation when the document is not valid" do
      file = Tempfile.new(["virus", ".exe"])
      exe = Rack::Test::UploadedFile.new(file.path, "application/x-msdownload")

      expect { post_annotation(attachment: exe) }.not_to change { Legislation::Annotation.count }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "redirects back to the draft version when the form is submitted without ajax" do
      post :create, params: {
        process_id: legislation_process.id,
        draft_version_id: draft_version.id,
        legislation_annotation: { quote: "texto",
                                  text: "Primer comentario",
                                  ranges: ranges,
                                  attachment: pdf }
      }

      expect(response).to redirect_to(legislation_process_draft_version_path(legislation_process,
                                                                             draft_version))
      expect(Legislation::Annotation.last.comments.first.documents.count).to eq 1
    end

    it "keeps working without a document" do
      expect { post_annotation }.to change { Legislation::Annotation.count }.by(1)
      expect(Legislation::Annotation.last.comments.first.documents).to be_empty
    end
  end
end
