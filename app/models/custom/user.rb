require_dependency Rails.root.join("app", "models", "user").to_s

class User
  has_one :legislator
  has_one :budget_manager
  has_many :legislation_processes, inverse_of: :user

  scope :residence_requested, -> { where.not(residence_requested_at: nil).where(residence_verified_at: nil) }
  scope :legislators, -> { joins(:legislator) }
  scope :budget_managers, -> { joins(:budget_manager) }
  scope :other, -> { where(gender: "other") }

  def legislator?
    legislator.present?
  end

  def budget_manager?
    budget_manager.present?
  end

  def show_welcome_screen?
    verification = Setting["feature.user.skip_verification"].present? ? true : unverified?
    sign_in_count == 1 && verification && !organization && !administrator? && !legislator? && !budget_manager?
  end

  def self.soft_minimum_required_age
    (Setting["soft_min_age_to_participate"] || 12).to_i
  end

  def residence_requested?
    residence_requested_at? && !residence_verified_at?
  end

  def residence_requested_age?
    age = (residence_requested_at - date_of_birth) / 1.year
    age >= User.soft_minimum_required_age && age < User.minimum_required_age
  end

  def residence_requested_foreign?
    foreign_residence?
  end

  def can_vote_budget_investment_for_this_budget?(budget_id)
    return false unless id # Esto no deberia pasar.
    return false unless budget_id # El budget_id es necesario.
    vote_registers = Vote.where(voter_id: id, votable_type: 'Budget::Investment', vote_flag: true)
    return true if vote_registers.empty? # El usuario no tiene votos
    max_votes_setting = Setting.find_by(key: 'max_votes_per_budget_per_user')
    return true unless max_votes_setting # El parametro max_votes_per_budget_per_user no existe
    max_votes_setting = max_votes_setting.value.to_i
    i = 0
    vote_registers.find_each do |vote|
      if vote&.votable&.budget_id == budget_id # Comprobamos que el voto pertenece a budget_id
        i+=1
      end
      # No hace falta seguir comprobando si hemos alcanzado el limite
      return false if i>=max_votes_setting # El usuario ha votado limite veces.
    end
    true
  end

  def voted_budget_investments(budget_id)
    list = []
    return list unless id
    return list unless budget_id
    return list unless Budget.exists?(id: budget_id)
    vote_registers = Vote.where(voter_id: id, votable_type: 'Budget::Investment', vote_flag: true)
    vote_registers.find_each do |vote|
      if vote&.votable&.budget_id == budget_id
        list << vote
      end
    end
    list
  end

  def number_of_budget_investment_votes_left_per_budget(budget_id)
    return 0 unless id
    return 0 unless budget_id # El budget_id es necesario
    vote_registers = Vote.where(voter_id: id, votable_type: 'Budget::Investment', vote_flag: true)
    max_votes_setting = Setting.where(key: 'max_votes_per_budget_per_user')
    return 100 if max_votes_setting.empty? # En teoria en este caso no se muestra.
    max_votes_setting=max_votes_setting.first.value.to_i
    return max_votes_setting if vote_registers.empty? # El usuario no tiene votos
    i = 0
    vote_registers.find_each do |vote|
      if vote&.votable&.budget_id == budget_id
        i+=1
      end
      return 0 if i>=max_votes_setting # Al usuario no le quedan votos.
    end
    return max_votes_setting-i
  end

  def count_my_budget_investments_for_budget(budget_id)
    return 0 unless id
    return 0 unless budget_id
    Budget::Investment.where(author_id: id, budget_id: budget_id).count.to_i
  end

  def count_my_remaining_budget_investments_for_budget(budget_id)
    my_budget_investments = count_my_budget_investments_for_budget(budget_id)
    max_proposals = Setting.where(key: 'max_proposals_per_budget_per_user')
    return 100 if max_proposals.empty? # No mostrar este valor.
    max_proposals = max_proposals.first.value.to_i
    return 0 if my_budget_investments>=max_proposals
    max_proposals-my_budget_investments
  end

  def has_votes?(budget_id)
    return false unless budget_id
    return false unless Budget.exists?(id: budget_id)
    vote_registers = Vote.where(voter_id: id, votable_type: 'Budget::Investment', vote_flag: true)
    vote_registers.find_each { |vote| return true if vote&.votable&.budget_id == budget_id }
    false
  end

  def self.first_or_initialize_for_gvlogin(data)
    gvlogin_email           = data.mail
    gvlogin_username        = "#{data.nombre}-GVLogin"
    gvlogin_user            = User.find_by(email: gvlogin_email)
    gvlogin_user || User.new(
      username: gvlogin_username,
      email: gvlogin_email,
      password: Devise.friendly_token[0, 20],
      terms_of_service: "1",
      confirmed_at: DateTime.current
    )
  end
end
