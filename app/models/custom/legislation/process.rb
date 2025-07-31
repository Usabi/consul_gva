load Rails.root.join("app", "models", "legislation", "process.rb")

class Legislation::Process
  include Filterable
  include Followable

  SORTING_OPTIONS = { id: "id", created_at: "created_at" }.freeze

  belongs_to :user, optional: true, inverse_of: :legislation_processes

  has_many :process_legislators, dependent: :destroy, foreign_key: "legislation_process_id" # rubocop:disable Rails/InverseOf
  has_many :legislators, through: :process_legislators

  after_create :create_default_question

  def self.processes_filters
    %w[preview_phase public_phase past relevance results]
  end

  scope :preview_phase, -> {
    where("(debate_phase_enabled = true and (debate_start_date <= :date and debate_end_date >= :date)) or
          (proposals_phase_enabled = true and (proposals_phase_start_date <= :date and proposals_phase_end_date >= :date))", date: Date.current) # rubocop:disable Layout/LineLength
  }
  scope :public_phase, -> { where("allegations_phase_enabled = true and (allegations_start_date <= :date and allegations_end_date >= :date)", date: Date.current) } # rubocop:disable Layout/LineLength

  scope :last_week, -> { where("created_at >= ?", 7.days.ago) }

  scope :results, -> { where(result_publication_enabled: true).where('result_publication_date <= :date', date: Date.current) }

  def searchable_values
    {
      user.username => "B"
    }.merge!(searchable_globalized_values)
  end

  def self.sort_by_title
    all.sort_by(&:title)
  end

  def self.search_by_title_or_id(search)
    with_joins = with_translations(Globalize.fallbacks(I18n.locale)).joins(:user)

    if search.to_s.match?(/^\d+$/)
      with_joins.where(legislation_processes: { id: search.to_i })
    else
      with_joins.where("users.username ILIKE :like_query OR
                        users.email ILIKE :like_query OR
                        legislation_process_translations.title ILIKE :like_query",
                       like_query: "%#{search}%")
    end
  end

  def self.scoped_filter(params, current_filter, advanced_search_terms)
    results = Legislation::Process
    results = results.filter_by(advanced_search_terms) if advanced_search_terms.present?
    if params[:min_total_supports].present?
      results = results.where("cached_votes_up >= ?", params[:min_total_supports])
    end
    if params[:max_total_supports].present?
      results = results.where("cached_votes_up <= ?", params[:max_total_supports])
    end

    results = results.by_tag(params[:tag_name])          if params[:tag_name].present?
    results = results.by_goal(params[:goal])             if params[:goal].present?
    results = results.by_target(params[:target])         if params[:target].present?

    results = results.search_by_title_or_id(params[:search].strip) if params[:search]
    results = results.send(current_filter) if current_filter.present?
    results
  end

  def self.order_filter(params)
    sorting_key = params[:sort_by]&.downcase&.to_sym
    allowed_sort_option = SORTING_OPTIONS[sorting_key]
    direction = params[:direction] == "desc" ? "desc" : "asc"

    if allowed_sort_option.present?
      order("#{allowed_sort_option} #{direction}")
    elsif sorting_key == :title
      direction == "asc" ? sort_by_title : sort_by_title.reverse
    else
      order(id: :desc)
    end
  end

  private

    def create_default_question
      Legislation::Question.create!(
        title: I18n.t("admin.legislation.processes.default_question_title"),
        process: self,
        author: user
      )
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error I18n.t("admin.legislation.processes.default_question_create_error", error: e.message)
    end
end
