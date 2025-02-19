require_dependency Rails.root.join("app", "controllers", "admin", "debates_controller").to_s

class Admin::DebatesController
  include Admin::HelpPagesActions

  def help_page
    @help_text_content = help_text(controller_name)
    render "admin/debates/help_pages/show"
  end

  has_filters %w[all], only: :index

  def index
    @debates = ::Debate.scoped_filter(params, @current_filter).order_filter(params)
    @debates = Kaminari.paginate_array(@debates) if @debates.is_a?(Array)
    @debates = @debates.page(params[:page]) unless request.format.csv?
    respond_to do |format|
      format.html
      format.csv do
        send_data Debate::Exporter.new(@debates).to_csv,
                  filename: "debates.csv"
      end
    end
  end

  private

    def resource_model
      Debate
    end
end
