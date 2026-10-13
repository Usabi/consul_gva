load Rails.root.join("app", "models", "document.rb")

class Document
  scope :visible, -> { where(hidden_at: nil) }
  scope :hidden, -> { where.not(hidden_at: nil) }

  def self.restricted_blob?(blob)
    ids = ActiveStorage::Attachment.where(blob_id: blob.id, record_type: "Document").pluck(:record_id)

    Document.where(id: ids).any?(&:restricted?)
  end

  def hidden?
    hidden_at.present?
  end

  # A document must not be served to the public when it was hidden by an
  # administrator or when the comment it belongs to is no longer visible.
  def restricted?
    return true if hidden?
    return false unless documentable_type == "Comment"

    comment = Comment.with_hidden.find_by(id: documentable_id)
    comment.nil? || comment.hidden? || comment.commentable&.hidden? || false
  end

  def hide
    update_column(:hidden_at, Time.current)
    touch_documentable
  end

  def restore
    update_column(:hidden_at, nil)
    touch_documentable
  end

  private

    def touch_documentable
      documentable&.touch
    end
end
