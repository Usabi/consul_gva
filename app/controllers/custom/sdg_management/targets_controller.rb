require_dependency Rails.root.join("app", "controllers", "sdg_management", "targets_controller").to_s

class SDGManagement::TargetsController
  load_and_authorize_resource class: "SDG::Target"

  def index
    @targets = @targets.sort
  end

  def edit
  end

  def update
    I18nContent.update(content_params, enabled_translations)

    redirect_to sdg_management_targets_path,
                notice: t("flash.actions.update.translation")
  end

  private

    def content_params
      params.require(:contents).values
    end

    def enabled_translations
      params.fetch(:enabled_translations, {}).select { |_, v| v == "1" }.keys
    end
end
