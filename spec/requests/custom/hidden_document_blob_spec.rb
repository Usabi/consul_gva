require "rails_helper"

describe "Hidden documents blob access" do
  let(:comment) { create(:comment) }
  let(:document) { create(:document, documentable: comment, user: comment.user) }
  let(:blob_path) { rails_blob_path(document.attachment, only_path: true) }
  let(:proxy_path) { rails_storage_proxy_path(document.attachment, only_path: true) }

  def disk_path_for(document)
    get rails_blob_path(document.attachment, only_path: true)
    URI.parse(response.location).request_uri
  end

  context "visible document" do
    it "is served to anonymous users" do
      get blob_path

      expect(response).to have_http_status(:redirect)
    end

    it "is served through the proxy route" do
      get proxy_path

      expect(response).to have_http_status(:ok)
    end
  end

  context "hidden document" do
    before { document.hide }

    it "is not served to anonymous users" do
      get blob_path

      expect(response).to have_http_status(:not_found)
    end

    it "is not served through the proxy route" do
      get proxy_path

      expect(response).to have_http_status(:not_found)
    end

    it "is not served to regular users, not even the comment author" do
      login_as(comment.user)
      get blob_path

      expect(response).to have_http_status(:not_found)
    end

    it "is not served by the disk service with a previously obtained URL" do
      document.restore
      disk_path = disk_path_for(document)
      get disk_path
      expect(response).to have_http_status(:ok)

      document.hide
      get disk_path

      expect(response).to have_http_status(:not_found)
    end

    it "is served to administrators so they can review it" do
      login_as(create(:administrator).user)
      get blob_path

      expect(response).to have_http_status(:redirect)
    end

    it "is served again after being restored" do
      document.restore
      get blob_path

      expect(response).to have_http_status(:redirect)
    end
  end

  context "document of a hidden comment" do
    it "is not served" do
      document
      comment.hide

      get blob_path

      expect(response).to have_http_status(:not_found)
    end
  end
end
