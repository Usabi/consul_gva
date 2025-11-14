class Admin::BulletinsController < Admin::BaseController
  load_and_authorize_resource

  def index
    @bulletins = Bulletin.all
  end

  def show
    @bulletin = Bulletin.find(params[:id])
  end

  def new
    @bulletin = Bulletin.new
  end

  def create
    @bulletin = Bulletin.new(bulletin_params)

    if @bulletin.save
      notice = t("admin.bulletins.create_success")
      redirect_to [:admin, @bulletin], notice: notice
    else
      render :new
    end
  end

  def edit
    @bulletin = Bulletin.find(params[:id])
  end

  def update
    @bulletin = Bulletin.find(params[:id])

    if @bulletin.update(bulletin_params)
      redirect_to [:admin, @bulletin], notice: t("admin.bulletins.update_success")
    else
      render :edit
    end
  end

  def destroy
    @bulletin = Bulletin.find(params[:id])
    @bulletin.destroy!

    redirect_to admin_bulletins_path, notice: t("admin.bulletins.delete_success")
  end

  def deliver
    @bulletin = Bulletin.find(params[:id])

    if @bulletin.valid?
      rendered_body = render_to_string(
        template: "admin/bulletin_templates/_#{@bulletin.template}",
        layout: false
      )
      segment = @bulletin.for_citizen_newsletter? ? @bulletin.citizen_newsletter_segment : "all_users"
      newsletter = Newsletter.create!(
        subject: @bulletin.title,
        segment_recipient: [segment],
        from: "no-reply@consul.dev",
        body: rendered_body,
        sent_at: Time.current
      )
      newsletter.delay.deliver
      @bulletin.add_sent_at_date
      flash[:notice] = t("admin.bulletins.send_success")
    else
      flash[:error] = t("admin.segment_recipient.invalid_recipients_segment")
    end

    redirect_to [:admin, @bulletin]
  end

  private

    def bulletin_params
      params.require(:bulletin).permit(allowed_params)
    end

    def allowed_params
      %i[title template]
    end
end
