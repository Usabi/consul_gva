require_dependency Rails.root.join("app", "controllers", "verification", "residence_controller").to_s

class Verification::ResidenceController
  def create
    @residence = Verification::Residence.new(residence_params.merge(user: current_user))
    if @residence.save
      # we don't want to use sms verification
      current_user.update!(unconfirmed_phone: "-", confirmed_phone: "-")

      if current_user.residence_requested?
        ahoy.track(:level_2_user_requested, user_id: current_user.id) rescue nil

        link_locale = I18n.locale == :val ? "va" : I18n.locale
        age_url = Verification::Residence.procedure_url(:age, link_locale)
        foreign_url = Verification::Residence.procedure_url(:foreign, link_locale)

        if current_user.residence_requested_foreign? && current_user.residence_requested_age?
          age_link = helpers.link_to t("verification.residence.create.flash.procedure"), age_url
          foreign_link = helpers.link_to t("verification.residence.create.flash.procedure"), foreign_url
          notice = t("verification.residence.create.flash.required_age_foreign_residence_request_form", age_link: age_link, foreign_link: foreign_link)
        elsif current_user.residence_requested_foreign?
          link = helpers.link_to t("verification.residence.create.flash.procedure"), foreign_url
          notice = t("verification.residence.create.flash.foreign_residence_request_form", link: link)
        elsif current_user.residence_requested_age?
          link = helpers.link_to t("verification.residence.create.flash.procedure"), age_url
          notice = t("verification.residence.create.flash.required_age_request_form", link: link, required_age: User.minimum_required_age)
        end

        redirect_to account_path, notice: notice
      else
        ahoy.track(:level_2_user, user_id: current_user.id) rescue nil
        current_user.update(verified_at: Time.current)
        redirect_to verified_user_path, notice: t("verification.residence.create.flash.success")
      end
    else
      render :new
    end
  end

  private

    def residence_params
      params.require(:residence).permit(allowed_params)
    end

    def allowed_params
      [:document_number, :document_type, :date_of_birth, :postal_code, :terms_of_service, :gender, :name, :first_surname, :last_surname, :foreign_residence]
    end
end
