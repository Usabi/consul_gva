require_dependency Rails.root.join("app", "models", "verification", "residence").to_s

class Verification::Residence
  validates :gender, :name, :first_surname, presence: true
  validates :last_surname, presence: true, if: -> { document_type == 1 }

  validate :postal_code_in_valencia
  validate :residence_in_valencia

  GENDERS = %i[male female other].freeze
  PROCEDURE_IDS = {
    age: 21470,
    foreign: 21540
  }.freeze

  undef gender
  attr_accessor :gender, :name, :first_surname, :last_surname, :foreign_residence

  def save
    return false unless valid?

    user.take_votes_if_erased_document(document_number, document_type)

    if !@census_data.valid? && foreign_residence? || Age.in_years(date_of_birth).in?(User.soft_minimum_required_age...User.minimum_required_age)
      residence_requested_at = Time.current
    else
      residence_verified_at = Time.current
    end

    user.update(document_number:        document_number,
                document_type:          document_type,
                geozone:                geozone,
                postal_code:            postal_code,
                date_of_birth:          date_of_birth.in_time_zone.to_datetime,
                gender:                 gender,
                residence_verified_at:  residence_verified_at,
                residence_requested_at: residence_requested_at,
                foreign_residence:      foreign_residence,
                services_results:       (@census_data.data if @census_data.is_a?(CensusApi::Response)))
  end

  def postal_code_in_valencia
    errors.add(:postal_code, I18n.t("verification.residence.new.error_not_allowed_postal_code")) unless valid_postal_code?
  end

  def allowed_age
    return if errors[:date_of_birth].any? || Age.in_years(date_of_birth) >= User.soft_minimum_required_age

    errors.add(:date_of_birth, I18n.t("verification.residence.new.error_not_allowed_age"))
  end

  def residence_in_valencia
    return if errors.any? # return to form with validation messages

    unless residency_valid?
      if @census_data.respond_to?(:error) && @census_data.error =~ /^Servicio no disponible/
        errors.add(:base, I18n.t("verification.residence.new.error_service_not_available"))
        return
      end

      errors.add(:postal_code, I18n.t("verification.residence.new.invalid_postal_code")) unless postal_code_valid?

      errors.add(:date_of_birth, I18n.t("verification.residence.new.invalid_date_of_birth")) unless date_of_birth_valid?

      errors.add(:residence_in_valencia, false)
      store_failed_attempt
      Lock.increase_tries(user)
    end
  end

  def store_failed_attempt
    FailedCensusCall.create(
      user:              user,
      document_number:   document_number,
      document_type:     document_type,
      date_of_birth:     date_of_birth,
      postal_code:       postal_code,
      foreign_residence: foreign_residence,
      services_results:  (@census_data.data if @census_data.respond_to?(:data)))
  end

  def self.procedure_url(type, locale)
    "https://www.gva.es/#{locale}/inicio/procedimientos?id_proc=#{PROCEDURE_IDS[type]}&version=amp"
  end

  private

    def retrieve_census_data
      other_data = { date_of_birth: date_of_birth, postal_code: postal_code, name: name, first_surname: first_surname, last_surname: last_surname }
      @census_data = CensusCaller.new.call(document_type, document_number, other_data)
    end

    def residency_valid?
      # If age service returns ok, foreign residence is checked and residence service returns no residence error, we return true
      return true if !@census_data.valid? &&
                     date_of_birth_valid? &&
                     foreign_residence? &&
                     @census_data.respond_to?(:error) &&
                     @census_data.error == "No residente"

      @census_data.valid? &&
        postal_code_valid? && date_of_birth_valid?
    end

    def postal_code_valid?
      @census_data.postal_code.to_s == postal_code
    end

    def date_of_birth_valid?
      @census_data.date_of_birth == date_of_birth
    end

    def valid_postal_code?
      postal_code =~ /^03|12|46/
    end

    def foreign_residence?
      foreign_residence == '1'
    end
end
