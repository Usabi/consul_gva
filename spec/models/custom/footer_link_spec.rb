require "rails_helper"

describe FooterLink do
  let(:footer_link) { build(:footer_link) }

  it "is valid" do
    expect(footer_link).to be_valid
  end

  describe "label" do
    it "is required" do
      footer_link.label = nil

      expect(footer_link).not_to be_valid
    end

    it "is at most 80 characters long" do
      footer_link.label = "a" * 81

      expect(footer_link).not_to be_valid
    end
  end

  describe "url" do
    it "is required" do
      footer_link.url = nil

      expect(footer_link).not_to be_valid
    end

    it "accepts absolute http and https urls" do
      footer_link.url = "https://www.gva.es/privacy"
      expect(footer_link).to be_valid

      footer_link.url = "http://www.gva.es"
      expect(footer_link).to be_valid
    end

    it "accepts internal paths" do
      footer_link.url = "/privacy"

      expect(footer_link).to be_valid
    end

    it "rejects dangerous or malformed urls" do
      ["javascript:alert(1)", "data:text/html,hi", "ftp://x.es", "not a url", "//evil.es"].each do |url|
        footer_link.url = url

        expect(footer_link).not_to be_valid, "expected #{url.inspect} to be invalid"
      end
    end

    it "is at most 255 characters long" do
      footer_link.url = "https://www.gva.es/#{"a" * 250}"

      expect(footer_link).not_to be_valid
    end
  end

  describe "position" do
    it "must be a non negative integer" do
      footer_link.position = -1
      expect(footer_link).not_to be_valid

      footer_link.position = 1.5
      expect(footer_link).not_to be_valid

      footer_link.position = 0
      expect(footer_link).to be_valid
    end
  end

  describe "scopes" do
    it ".visible returns only visible links ordered by position" do
      second = create(:footer_link, position: 2)
      first = create(:footer_link, position: 1)
      create(:footer_link, position: 0, visible: false)

      expect(FooterLink.visible).to eq [first, second]
    end
  end
end
