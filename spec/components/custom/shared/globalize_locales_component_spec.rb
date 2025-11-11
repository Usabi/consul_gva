require "rails_helper"

describe Shared::GlobalizeLocalesComponent do
  describe "Language selector" do
    it "only includes enabled locales" do
      Setting["locales.enabled"] = "en nl"

      I18n.with_locale(:en) do
        render_inline Shared::GlobalizeLocalesComponent.new

        expect(page).to have_select "Current language", options: ["Eng"]
      end

      I18n.with_locale(:es) do
        render_inline Shared::GlobalizeLocalesComponent.new

        expect(page).to have_select "Idioma actual", options: []
      end
    end
  end

  describe "Add language selector" do
    it "only includes enabled locales" do
      Setting["locales.enabled"] = "en nl"

      render_inline Shared::GlobalizeLocalesComponent.new

      expect(page).to have_select "Add language", options: ["", "Eng", "Nederlands"]
    end
  end
end
