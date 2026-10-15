require "rails_helper"

describe Comment do
  describe "documents" do
    it "can have documents attached" do
      comment = create(:comment)
      document = create(:document, documentable: comment, user: comment.user)

      expect(comment.reload.documents).to eq([document])
    end

    it "accepts nested attributes for documents" do
      user = create(:user)
      comment = build(:comment, user: user)
      comment.documents_attributes = [{
        title: "informe.pdf",
        user_id: user.id,
        attachment: Rack::Test::UploadedFile.new("spec/fixtures/files/empty.pdf")
      }]

      expect(comment.save).to be true
      expect(comment.documents.count).to eq(1)
    end

    it "destroys documents when the comment is destroyed" do
      comment = create(:comment)
      create(:document, documentable: comment, user: comment.user)

      expect { comment.destroy! }.to change { Document.count }.by(-1)
    end
  end
end

describe Document do
  describe "hiding" do
    let(:comment) { create(:comment) }
    let(:document) { create(:document, documentable: comment, user: comment.user) }

    it "is visible by default" do
      expect(document).not_to be_hidden
      expect(Document.visible).to include(document)
    end

    it "#hide marks the document as hidden and keeps the record" do
      document.hide

      expect(document.reload).to be_hidden
      expect(document.hidden_at).to be_present
      expect(Document.visible).not_to include(document)
    end

    it "#restore makes a hidden document visible again" do
      document.hide
      document.restore

      expect(document.reload).not_to be_hidden
    end
  end
end
