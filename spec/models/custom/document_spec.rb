require "rails_helper"

describe Document do
  it_behaves_like "document validations", "budget_investment_document"
  it_behaves_like "document validations", "proposal_document"

  context "scopes" do
    describe "#admin" do
      it "returns admin documents" do
        admin_document = create(:document, :admin)

        expect(Document.admin).to eq [admin_document]
      end

      it "does not return user documents" do
        create(:document, admin: false)

        expect(Document.admin).to be_empty
      end
    end
  end

  context 'url' do
    describe 'with new' do
      let!(:document) { build :document, :budget_investment_document }

      it 'persists document' do
        expect { document.save }.to change { Document.count }.by(1)
      end

      it 'is accessible' do
        document.save
        expect(File.exist?(file_path(document.reload.attachment.url))).to eq(true)
      end
    end

    describe 'with persisted' do
      let!(:document) { create :document, :budget_investment_document }
      let!(:url) { document.attachment.url }

      context 'when changing title' do
        it 'updates document' do
          expect { document.update(title: 'New title') }.to_not change { Document.count }
        end

        it 'is accessible' do
          document.update(title: 'New title')
          expect(File.exist?(file_path(document.reload.attachment.url))).to eq(true)
          expect(document.attachment.url).to eq(url)
        end
      end
    end

    describe 'with removed' do
      let!(:document) { create :document, :budget_investment_document }
      let!(:url) { document.attachment.url }

      it 'destroys document' do
        expect { document.destroy }.to change { Document.count }.by(-1)
      end

      it 'is not accessible' do
        document.destroy
        expect(File.exist?(file_path(url))).to eq(false)
      end
    end
  end

  def file_path(path)
    Rails.root.join('public').to_s + path
  end
end
