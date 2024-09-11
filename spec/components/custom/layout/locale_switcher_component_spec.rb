require "rails_helper"

describe Layout::LocaleSwitcherComponent do
  let(:component) { Layout::LocaleSwitcherComponent.new }

  around do |example|
    with_request_url("/") { example.run }
  end

  context "with es and val languages" do
    before do
      allow(I18n).to receive(:available_locales).and_return(%i[es val])
      allow(I18n).to receive(:locale).and_return(:val)
    end

    it "renders a form to select the language" do
      render_inline component

      expect(page).to have_css "form"
      expect(page).to have_content "Val"
      expect(page).to have_content "Cast"
    end

    it "selects the current locale" do
      render_inline component

      expect(page).to have_checked_field("local-Val")
    end
  end
end
