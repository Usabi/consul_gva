namespace :milestone do
  desc "Create default milestone"
  task create_status: :environment do
    %w[drafting processing execution executed].each do |state|
      status = Milestone::Status.find_or_create_by(kind: state)
      %i[val es].each do |locale|
        I18n.locale = locale
        status.send(:"name_#{locale}=", I18n.t("budgets.milestone.statuses.#{state}"))
        status.send(:"description_#{locale}=", I18n.t("budgets.milestone.statuses.#{state}_description"))
        status.save!
      end
    end
  end
end
