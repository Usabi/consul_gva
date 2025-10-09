class Admin::CitizenOpinionsController < Admin::BaseController
  load_and_authorize_resource

  def index
    @citizen_opinions = CitizenOpinion.page(params[:page])
  end
end
