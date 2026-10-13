class Admin::FooterLinksController < Admin::BaseController
  include Translatable

  load_and_authorize_resource

  def index
    @footer_links = FooterLink.sorted.includes(:translations)
  end

  def new
  end

  def create
    @footer_link = FooterLink.new(footer_link_params)

    if @footer_link.save
      redirect_to admin_footer_links_path, notice: t("admin.footer_links.create.notice")
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @footer_link.update(footer_link_params)
      redirect_to admin_footer_links_path, notice: t("admin.footer_links.update.notice")
    else
      render :edit
    end
  end

  def destroy
    @footer_link.destroy!
    redirect_to admin_footer_links_path, notice: t("admin.footer_links.destroy.notice")
  end

  private

    def footer_link_params
      params.require(:footer_link).permit(allowed_params)
    end

    def allowed_params
      [:url, :position, :visible, translation_params(FooterLink)]
    end

    def resource
      @footer_link ||= FooterLink.find(params[:id])
    end
end
