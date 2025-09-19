class Admin::Legislation::CouncilsController < Admin::BaseController
  include Translatable

  load_and_authorize_resource :council, class: "Legislation::Council"
  # load_and_authorize_resource

  # before_action :load_councils, only: [:index]

  def index
    @counicls = Legislation::Council.all
  end

  def new
    @council = Legislation::Council.new
  end

  def create
    @council = Legislation::Council.new(council_params)

    if @council.save
      redirect_to admin_legislation_councils_path, notice: t("admin.council.create.notice")
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @council.update(council_params)
      redirect_to admin_legislation_councils_path, notice: t("admin.council.update.notice")
    else
      render :edit
    end
  end

  def destroy
    @council.destroy!
    redirect_to admin_legislation_councils_path, notice: t("admin.council.delete.notice")
  end

  private

    def load_councils
      @councils = Legislation::Council.all
    end

    def council_params
      params.require(:legislation_council).permit(allowed_params)
    end

    def allowed_params
      [:active, translation_params(Legislation::Council)]
    end
end
