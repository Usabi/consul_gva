class Admin::ManagementNewslettersController < Admin::BaseController
  load_and_authorize_resource

  def index
    @management_newsletters = @management_newsletters.page(params[:page])
  end

  def create
    @management_newsletter = ManagementNewsletter.new(management_newsletter_params)
    @management_newsletter.save!

    redirect_to admin_management_newsletters_path
  end

  def show
    @management_newsletter = ManagementNewsletter.find(params[:id])
  end

  def resend
    @management_newsletter = ManagementNewsletter.find(params[:id])

    if @management_newsletter.deliver
      redirect_to admin_management_newsletters_path,
                  notice: t("admin.management_newsletters.resend.success")
    else
      redirect_to admin_management_newsletters_path,
                  alert: t("admin.management_newsletters.resend.error")
    end
  end

  def update_frequency
    frequency = params[:frequency]
    if %w[daily weekly].include?(frequency)
      Setting["management_newsletter_frequency"] = frequency
      flash[:notice] = t("admin.management_newsletters.configuration.updated")
    else
      flash[:alert] = t("admin.management_newsletters.configuration.invalid")
    end
    redirect_to admin_management_newsletters_path
  end

  private

    def management_newsletter_params
      params.require(:management_newsletter).permit(:status)
    end
end
