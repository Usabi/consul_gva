class Comments::AttachmentFieldComponent < ApplicationComponent
  attr_reader :css_id, :name

  def initialize(css_id, name: "comment[attachment]")
    @css_id = css_id
    @name = name
  end

  private

    def attachment_accept
      Setting.accepted_content_types_for("documents").map do |content_type|
        content_type == "jpg" ? ".jpg,.jpeg" : ".#{content_type}"
      end.join(",")
    end

    def attachment_help
      t("comments.form.attachment_help",
        accepted_content_types: Document.humanized_accepted_content_types,
        max_file_size: Comment.max_file_size)
    end
end
