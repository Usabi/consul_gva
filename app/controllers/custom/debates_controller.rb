require_dependency Rails.root.join("app", "controllers", "debates_controller").to_s

class DebatesController
  private

    def allowed_params
      [:tag_list, :terms_of_service, :geozone_id, :related_sdg_list, translation_params(Debate)]
    end
end
