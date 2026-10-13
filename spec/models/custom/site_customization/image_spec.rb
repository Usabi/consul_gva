require "rails_helper"

describe SiteCustomization::Image do
  describe "footer logos" do
    it "is valid with a 230x96 image for logo_footer_gva" do
      image = build(:site_customization_image,
                    name: "logo_footer_gva",
                    image: fixture_file_upload("footer_logo_gva-230x96.png"))

      expect(image).to be_valid
    end

    it "is valid with a 154x52 image for logo_footer_participa" do
      image = build(:site_customization_image,
                    name: "logo_footer_participa",
                    image: fixture_file_upload("footer_logo_participa-154x52.png"))

      expect(image).to be_valid
    end

    it "is not valid when the dimensions do not match" do
      image = build(:site_customization_image,
                    name: "logo_footer_gva",
                    image: fixture_file_upload("footer_logo_participa-154x52.png"))

      expect(image).not_to be_valid
      expect(image.errors[:image]).to be_present
    end

    it "is not valid with a non image mime type" do
      image = build(:site_customization_image,
                    name: "logo_footer_gva",
                    image: fixture_file_upload("clippy.pdf"))

      expect(image).not_to be_valid
    end
  end
end
