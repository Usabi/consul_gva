module Custom::UsersHelper
  def current_legislator?
    current_user&.legislator?
  end

  def current_budget_manager?
    current_user&.budget_manager?
  end

  def special_verification_reason(user)
    text = []
    text << t("admin.users.columns.residence_requested_reasons.foreign_residence") if user.residence_requested_foreign?
    text << t("admin.users.columns.residence_requested_reasons.older_than_soft_minimum_required_age", required_age: User.minimum_required_age) if user.residence_requested_age?
    text.join(", ")
  end
end
