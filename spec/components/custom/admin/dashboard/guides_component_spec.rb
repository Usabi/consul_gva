require "rails_helper"

describe Admin::Dashboard::GuidesComponent do
  it "links the guides to the URLs configured in settings" do
    Setting["admin_guide_url"] = "https://example.com/admin.pdf"
    Setting["legislator_guide_url"] = "https://example.com/legislator.pdf"

    render_inline Admin::Dashboard::GuidesComponent.new

    expect(page).to have_link href: "https://example.com/admin.pdf"
    expect(page).to have_link href: "https://example.com/legislator.pdf"
  end

  it "hides the download button of a guide without configured URL" do
    Setting["admin_guide_url"] = "https://example.com/admin.pdf"
    Setting["legislator_guide_url"] = ""

    render_inline Admin::Dashboard::GuidesComponent.new

    expect(page).to have_css ".guide-actions a", count: 1
    expect(page).to have_link href: "https://example.com/admin.pdf"
  end

  it "shows the contact email and website configured in settings" do
    Setting["help_contact_email"] = "ayuda@gva.es"
    Setting["help_contact_website"] = "https://participem.gva.es"

    render_inline Admin::Dashboard::GuidesComponent.new

    expect(page).to have_link "ayuda@gva.es", href: "mailto:ayuda@gva.es"
    expect(page).to have_link "https://participem.gva.es", href: "https://participem.gva.es"
  end

  it "hides the contact links that are not configured" do
    Setting["help_contact_email"] = "ayuda@gva.es"
    Setting["help_contact_website"] = ""

    render_inline Admin::Dashboard::GuidesComponent.new

    expect(page).to have_link "ayuda@gva.es"
    expect(page).to have_css ".contact-info a", count: 1
  end

  it "hides the contact section when nothing is configured" do
    Setting["help_contact_email"] = ""
    Setting["help_contact_website"] = ""

    render_inline Admin::Dashboard::GuidesComponent.new

    expect(page).not_to have_css ".contact-info"
  end
end
