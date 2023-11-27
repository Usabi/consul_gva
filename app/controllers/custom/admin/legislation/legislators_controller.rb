class Admin::Legislation::LegislatorsController < Admin::Legislation::BaseController
  load_and_authorize_resource :process, class: "Legislation::Process"

  def edit
  end
end
