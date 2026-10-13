require "rails_helper"

describe "Admin footer links", :admin do
  scenario "Index lists links ordered by position" do
    create(:footer_link, label: "Second link", position: 2)
    create(:footer_link, label: "First link", position: 1)

    visit admin_footer_links_path

    expect("First link").to appear_before("Second link")
  end

  scenario "Create a link" do
    visit admin_footer_links_path
    click_link "Create footer link"

    fill_in "Label", with: "Aviso legal"
    fill_in "URL", with: "https://www.gva.es/aviso-legal"
    fill_in "Position", with: "3"
    click_button "Save footer link"

    expect(page).to have_content "Footer link created successfully"
    expect(page).to have_content "Aviso legal"
    expect(FooterLink.last.url).to eq "https://www.gva.es/aviso-legal"
  end

  scenario "Create a link with an invalid url shows validation errors" do
    visit new_admin_footer_link_path

    fill_in "Label", with: "Malicious"
    fill_in "URL", with: "javascript:alert(1)"
    click_button "Save footer link"

    expect(page).to have_css "#error_explanation"
    expect(page).to have_content "is invalid"
    expect(FooterLink.count).to eq 0
  end

  scenario "Create a link without label shows validation errors" do
    visit new_admin_footer_link_path

    fill_in "URL", with: "/privacy"
    click_button "Save footer link"

    expect(page).to have_content "can't be blank"
    expect(FooterLink.count).to eq 0
  end

  scenario "Update a link" do
    link = create(:footer_link, label: "Old label", url: "/old")

    visit edit_admin_footer_link_path(link)
    fill_in "Label", with: "New label"
    uncheck "Visible"
    click_button "Save footer link"

    expect(page).to have_content "Footer link updated successfully"
    expect(link.reload.label).to eq "New label"
    expect(link.visible).to be false
  end

  scenario "Destroy a link" do
    link = create(:footer_link, label: "Delete me")

    visit admin_footer_links_path
    accept_confirm do
      within("tr", text: "Delete me") { click_button "Delete" }
    end

    expect(page).to have_content "Footer link deleted successfully"
    expect(FooterLink.exists?(link.id)).to be false
  end
end
