class Admin::CitizenNewslettersController < Admin::BaseController
  load_and_authorize_resource

  def index
    @citizen_newsletters = @citizen_newsletters.newest_first.page(params[:page])
  end

  def show
    @citizen_newsletter = CitizenNewsletter.find(params[:id])
  end

  def create
    @citizen_newsletter = CitizenNewsletter.new(citizen_newsletter_params)
    @citizen_newsletter.save!

    redirect_to admin_citizen_newsletters_path
  end

  def resend
    @citizen_newsletter = CitizenNewsletter.find(params[:id])

    begin
      @citizen_newsletter.deliver
      @citizen_newsletter.mark_as_sent
      redirect_to admin_citizen_newsletters_path,
                  notice: t("admin.citizen_newsletters.resend.success")
    rescue StandardError => e
      Rails.logger.error "Failed to resend citizen newsletter: #{e.message}"
      @citizen_newsletter.mark_as_failed
      redirect_to admin_citizen_newsletters_path,
                  alert: t("admin.citizen_newsletters.resend.error")
    end
  end

  private

    def citizen_newsletter_params
      params.require(:citizen_newsletter).permit(:status)
    end
end
