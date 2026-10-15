# Active Storage controllers are public by design: anyone who knows a signed
# blob URL can download the file. Documents hidden by an administrator (or
# belonging to a hidden comment) must not be reachable through any of them
# (redirect, proxy, representations or disk service), so every request is
# checked here. Administrators and moderators keep access in order to review the content.
module HiddenDocumentBlobGuard
  extend ActiveSupport::Concern

  included do
    before_action :block_restricted_document_blob
  end

  private

    def block_restricted_document_blob
      blob = requested_blob
      return if blob.blank? || !Document.restricted_blob?(blob)
      return if current_user&.administrator? || current_user&.moderator?

      head :not_found
    end

    def requested_blob
      signed_id = params[:signed_blob_id].presence || params[:signed_id].presence

      if signed_id
        ActiveStorage::Blob.find_signed(signed_id)
      elsif params[:encoded_key].present?
        key = ActiveStorage.verifier.verified(params[:encoded_key], purpose: :blob_key)
        ActiveStorage::Blob.find_by(key: key[:key]) if key
      end
    end
end
