class Admin::SiteCustomization::HelpTextsController < Admin::SiteCustomization::BaseController
  include Translatable
  load_and_authorize_resource :help_text, class: "SiteCustomization::HelpText"

  def index
    @help_texts = SiteCustomization::HelpText.order(id: :asc).page(params[:page])
  end

  def show
    raise ActionController::RoutingError, "Not Found" unless @help_text
  end

  def create
    if @help_text.save
      notice = t("admin.site_customization.help_texts.create.notice")
      redirect_to admin_site_customization_help_texts_path, notice: notice
      return
    end

    flash.now[:error] = t("admin.site_customization.help_texts.create.error")
    render :new
  end

  def update
    if @help_text.update(help_text_params)
      notice = t("admin.site_customization.help_texts.update.notice")
      redirect_to admin_site_customization_help_texts_path, notice: notice
      return
    end

    flash.now[:error] = t("admin.site_customization.help_texts.update.error")
    render :edit
  end

  def destroy
    @help_text.destroy!
    notice = t("admin.site_customization.help_texts.destroy.notice")
    redirect_to admin_site_customization_help_texts_path, notice: notice
  end

  private

    def help_text_params
      params.require(:site_customization_help_text).permit(allowed_params)
    end

    def allowed_params
      attributes = [:section]

      [*attributes, translation_params(SiteCustomization::HelpText)]
    end

    def resource
      SiteCustomization::HelpText.find(params[:id])
    end
end
