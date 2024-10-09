require "rails_helper"

describe Layout::SubnavigationComponent do
  let(:component) do
    Layout::SubnavigationComponent.new
  end

  it "renders tabs and links properly styled" do
    render_inline component

    expect(page).to have_link "Debates"
    expect(page).to have_link "Proposals"
    expect(page).to have_link "Voting"
    expect(page).to have_link "Collaborative legislation"
    expect(page).to have_link "Participatory budgeting"
    expect(page).to have_link "Help"
    expect(page).to have_link "Resources"
    expect(page).to have_css "a[href='https://participem.gva.es/en/portal-de-participacion']"
  end

  describe "with val local" do
    before do
      allow(I18n).to receive(:locale).and_return(:val)
    end

    it "resource link has local va" do
      render_inline component

      expect(page).to have_css "a[href='https://participem.gva.es/va/portal-de-participacion']"
    end
  end

  describe "with cast local" do
    before do
      allow(I18n).to receive(:locale).and_return(:cast)
    end

    it "resource link has local es" do
      render_inline component

      expect(page).to have_css "a[href='https://participem.gva.es/es/portal-de-participacion']"
    end
  end
end
