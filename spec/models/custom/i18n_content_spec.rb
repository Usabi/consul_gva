require "rails_helper"

describe I18nContent do
  describe ".translations_for" do
    it "groups every footer text in the footer tab" do
      keys = I18nContent.translations_for(:footer)

      expect(keys).to include "layouts.footer.privacy",
                              "layouts.footer.conditions",
                              "layouts.footer.accessibility",
                              "layouts.footer.citizen_opinions",
                              "layouts.footer.contact_us_short",
                              "layouts.footer.copyright",
                              "layouts.footer.description",
                              "application.slogan_text.footer"
    end

    it "only includes footer texts in the footer tab" do
      keys = I18nContent.translations_for("footer")

      expect(keys).to all(match(/footer/))
    end

    it "keeps the other tabs working" do
      expect(I18nContent.translations_for(:layouts)).to include "layouts.footer.privacy"
    end
  end

  describe "information texts tabs" do
    it "includes the footer tab" do
      tabs = Class.new { include Custom::SiteCustomizationHelper }.new.custom_information_texts_tabs

      expect(tabs).to include :footer
    end
  end
end
