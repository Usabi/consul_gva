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

  context '#fix_attachment_path' do
    describe 'with new' do
      let!(:document) { build :document, :budget_investment_document }

      it 'is accessible' do
        expect(document).to_not receive(:fix_attachment_path)
        document.save
        expect(File.exist?(document.reload.attachment.path)).to eq(true)
      end
    end

    describe 'with persisted' do
      let!(:document) { create :document, :budget_investment_document }

      context 'when changing title' do
        it 'is accessible' do
          expect(document).to receive(:fix_attachment_path).and_call_original
          document.update(title: 'New title')
          expect(File.exist?(document.reload.attachment.path)).to eq(true)
        end
      end

      context 'when file not broken' do
        it 'is not fixed' do
          expect(File).to receive(:exist?).once.and_return(true)
          expect(File).to_not receive(:rename)
          document.update(title: 'New title')
        end
      end

      context 'when correct file not in folder' do
        it 'is not renamed' do
          expect(File).to receive(:exist?).twice.and_return(false)
          expect(File).to_not receive(:rename)
          document.update(title: 'New title')
        end
      end

      context 'when changing another attribute' do
        it 'is accessible' do
          expect(document).to_not receive(:fix_attachment_path)
          document.update(admin: !document.admin)
          expect(File.exist?(document.reload.attachment.path)).to eq(true)
        end
      end
    end

    describe 'with removed' do
      let!(:document) { create :document, :budget_investment_document }
      let!(:path) { document.attachment.path }

      it 'is not accessible' do
        expect(document).to_not receive(:fix_attachment_path)
        document.destroy
        expect(File.exist?(path)).to eq(false)
      end
    end
  end
end
