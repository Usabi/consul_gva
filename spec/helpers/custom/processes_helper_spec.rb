require "rails_helper"

describe Custom::ProcessesHelper do
  describe "#xls_comments" do
    let(:sheet) { Axlsx::Package.new.workbook.add_worksheet(name: "Summary") }
    let(:link) { sheet.workbook.styles.add_style(fg_color: "0000FF", u: true) }
    let(:comment) { create(:comment) }

    before { helper.extend(Rails.application.routes.url_helpers) }

    it "adds a linked row per visible document of each comment" do
      document = create(:document, documentable: comment, user: comment.user)
      create(:document, documentable: comment, user: comment.user, hidden_at: Time.current)

      helper.xls_comments(sheet, link, [comment])

      values = sheet.rows.map { |row| row.cells.map(&:value) }.flatten
      expect(values).to include(document.title)
      expect(values).to include(a_string_starting_with("http://test.host/rails/active_storage/"))
      expect(sheet.rows.size).to eq 2
      expect(sheet.hyperlinks.map(&:location)).to include(
        a_string_starting_with("http://test.host/rails/active_storage/")
      )
    end

    it "adds nothing extra for comments without documents" do
      helper.xls_comments(sheet, link, [comment])

      expect(sheet.rows.size).to eq 1
    end
  end
end
