require "rails_helper"

describe Tenant do
  describe "#rename_storage with custom Disk service" do
    it "does not rename storage folders when updating the schema with Disk service" do
      tenant = create(:tenant, schema: "original")

      Tenant.switch("original") do
        Setting.reset_defaults
        create(:image)
      end

      # With Disk service (not TenantDisk), File.rename should not be called
      # because there are no tenant-specific folders to rename
      expect(File).not_to receive(:rename)

      tenant.update!(schema: "renamed")

      Tenant.switch("renamed") do
        image = Image.first
        # Image should still exist and be accessible
        expect(image).to be_present
        expect(image.file_path).to include "storage/"
        # But should not include tenant-specific paths
        expect(image.file_path).not_to include "tenants"
        expect(image.file_path).not_to include "original"
        expect(image.file_path).not_to include "renamed"
      end
    end
  end
end
