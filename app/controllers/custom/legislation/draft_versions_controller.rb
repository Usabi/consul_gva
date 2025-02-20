load Rails.root.join("app", "controllers", "legislation", "draft_versions_controller.rb")

class Legislation::DraftVersionsController
  private

    def visible_draft_versions
      if current_user&.administrator || current_user&.legislator
        @process.draft_versions
      else
        @process.draft_versions.published
      end
    end
end
