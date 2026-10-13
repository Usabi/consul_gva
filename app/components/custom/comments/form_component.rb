class Comments::FormComponent < ApplicationComponent; end
load Rails.root.join("app", "components", "comments", "form_component.rb")

class Comments::FormComponent
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
