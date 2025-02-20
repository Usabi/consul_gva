load Rails.root.join("app", "controllers", "debates_controller.rb")

class DebatesController
  before_action :load_geozones, only: [:edit, :map]

  def map
    @debate = Debate.new
    @tag_cloud = tag_cloud
  end

  private

    def allowed_params
      [:tag_list, :terms_of_service, :geozone_id, :related_sdg_list, translation_params(Debate)]
    end
end
