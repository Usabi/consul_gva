require "rails_helper"

describe "Debates" do
  describe "Social share buttons" do
    context "On desktop browsers" do
      scenario "Shows links to share on facebook, twitter, whatsapp and linkedin" do
        visit debate_path(create(:debate))

        within(".social-share-button") do
          expect(page.all("a").count).to be(4)
          expect(page).to have_link "Share to Facebook"
          expect(page).to have_link "Share to Twitter"
          expect(page).to have_link "Share to WhatsApp"
          expect(page).to have_link "Share to Linkedin"
        end
      end
    end

    context "On small devices", :small_window do
      scenario "Shows links to share including whatsapp web and linkedin" do
        visit debate_path(create(:debate))

        within(".social-share-button") do
          expect(page.all("a").count).to be(5)
          expect(page).to have_link "Share to Facebook"
          expect(page).to have_link "Share to Twitter"
          expect(page).to have_link "Share to Telegram"
          expect(page).to have_link "Share to WhatsApp"
          expect(page).to have_link "Share to Linkedin"
        end
      end
    end
  end
end
