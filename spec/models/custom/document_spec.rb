require "rails_helper"

describe Document do
  describe "position attribute" do
    it "stores and retrieves position value" do
      proposal = create(:proposal)
      document = create(:document, documentable: proposal, position: 3)

      expect(document.reload.position).to eq(3)
    end

    it "allows documents to have different positions" do
      proposal = create(:proposal)
      doc1 = create(:document, documentable: proposal, position: 1)
      doc2 = create(:document, documentable: proposal, position: 2)

      expect(Document.where(documentable: proposal).order(:position).map(&:position)).to eq([1, 2])
    end
  end
end
