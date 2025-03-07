class Admin::AlertMessagesController < Admin::BaseController
  include Translatable

  has_filters %w[all with_active with_inactive], only: :index

  before_action :alert_message_sections, only: [:edit, :new, :create, :update]

  respond_to :html, :js

  load_and_authorize_resource

  def index
    @alert_messages = AlertMessage.send(@current_filter).page(params[:page])
  end

  def create
    @alert_message = AlertMessage.new(alert_message_params)
    if @alert_message.save
      redirect_to admin_alert_messages_path, notice: t("admin.alert_messages.create.notice")
    else
      render :new
    end
  end

  def update
    if @alert_message.update(alert_message_params)
      redirect_to admin_alert_messages_path, notice: t("admin.alert_messages.update.notice")
    else
      render :edit
    end
  end

  def destroy
    @alert_message.destroy!
    redirect_to admin_alert_messages_path, notice: t("admin.alert_messages.destroy.notice")
  end

  def self.flash_keys
    FLASH_KEYS
  end

  private

    def alert_message_params
      params.require(:alert_message).permit(allowed_params)
    end

    def allowed_params
      [:target_url, :active, :flash_key,
       translation_params(AlertMessage),
       web_section_ids: []]
    end

    def alert_message_sections
      @alert_message_sections = WebSection.all
    end

    def resource
      @alert_message ||= AlertMessage.find(params[:id])
    end
end
