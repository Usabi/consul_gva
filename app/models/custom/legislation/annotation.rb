load Rails.root.join("app", "models", "legislation", "annotation.rb")

class Legislation::Annotation
  # Uploaded file sent along with the annotation; it is attached to the
  # first comment, which is created from the annotation text.
  attr_accessor :attachment

  private

    def create_first_comment
      comment = comments.build(body: text, user: author)
      return comment.save if attachment.blank?

      comment.documents.build(user: author, title: attachment.original_filename, attachment: attachment)
      comment.save!
    end
end
