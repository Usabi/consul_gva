require_dependency Rails.root.join("app", "controllers", "admin", "legislation", "processes_controller").to_s

class Admin::Legislation::ProcessesController
  include Search

  def index
    @processes = ::Legislation::Process.send(@current_filter)
    if @search_terms.present?
      if @search_terms.to_i.positive?
        @processes = @processes.where(id: @search_terms)
      else
        @processes = @processes.search(@search_terms)
      end
    end

    @processes = @processes.order(start_date: :desc).accessible_by(current_ability)
                 .page(params[:page])
  end

  def create
    @process.user = current_user
    if @process.save
      link = legislation_process_path(@process)
      notice = t("admin.legislation.processes.create.notice", link: link)
      redirect_to edit_admin_legislation_process_path(@process), notice: notice
    else
      flash.now[:error] = t("admin.legislation.processes.create.error")
      render :new
    end
  end
end
