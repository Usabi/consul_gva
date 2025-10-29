require "rails_helper"

describe Attachable do
  describe "custom storage configuration" do
    it "stores attachments for the default tenant in the default folder" do
      file_path = build(:image).file_path

      expect(file_path).to include "storage/"
      expect(file_path).not_to include "storage//"
      expect(file_path).not_to include "tenants"
    end

    it "stores attachments using Disk service without tenant-specific folders" do
      # With the custom configuration using Disk service instead of TenantDisk,
      # all attachments are stored in the same root folder regardless of tenant
      allow(Tenant).to receive(:current_schema).and_return("custom-tenant")

      image = build(:image)
      file_path = image.file_path

      # File path should not include tenant-specific folders
      expect(file_path).to include "storage/"
      expect(file_path).not_to include "tenants"
      expect(file_path).not_to include "custom-tenant"
    end
  end
end
