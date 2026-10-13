require "rails_helper"

describe Layout::FooterComponent do
  describe "logos" do
    it "renders the default logos when none is customized" do
      render_inline Layout::FooterComponent.new

      expect(page).to have_css "img[alt='Logo gva'][src*='logo-gva']"
      expect(page).to have_css "img[alt='Logo participa'][src*='logo-participa']"
    end

    it "renders the customized logos when uploaded from the admin" do
      create(:site_customization_image,
             name: "logo_footer_gva",
             image: fixture_file_upload("footer_logo_gva-230x96.png"))

      render_inline Layout::FooterComponent.new

      expect(page).to have_css "img[alt='Logo gva'][src*='footer_logo_gva']"
      expect(page).to have_css "img[alt='Logo participa'][src*='logo-participa']"
    end
  end

  describe "legal links" do
    it "renders the default links when there are no footer links configured" do
      render_inline Layout::FooterComponent.new

      page.find(".subfooter .privacy") do |privacy|
        expect(privacy).to have_css "a[href='/privacy']"
        expect(privacy).to have_css "a[href='/conditions']"
        expect(privacy).to have_css "a[href='/accessibility']"
      end
    end

    it "renders only the visible configured links ordered by position" do
      create(:footer_link, label: "Second", url: "https://www.gva.es/b", position: 2)
      create(:footer_link, label: "First", url: "/first", position: 1)
      create(:footer_link, label: "Hidden", url: "/hidden", position: 0, visible: false)

      render_inline Layout::FooterComponent.new

      page.find(".subfooter .privacy") do |privacy|
        links = privacy.all("a").select { |a| %w[First Second Hidden].include?(a.text) }

        expect(links.map(&:text)).to eq %w[First Second]
        expect(privacy).to have_link "First", href: "/first"
        expect(privacy).to have_link "Second", href: "https://www.gva.es/b"
        expect(privacy).not_to have_link "Hidden"
        expect(privacy).not_to have_css "a[href='/privacy']"
      end
    end

    it "opens external links with a safe rel attribute" do
      create(:footer_link, label: "External", url: "https://www.gva.es/b")

      render_inline Layout::FooterComponent.new

      expect(page).to have_css "a[href='https://www.gva.es/b'][rel~=noopener][rel~=external]"
    end
  end
end
