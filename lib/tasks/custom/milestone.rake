namespace :milestone do
  desc "Create default milestone"
  task create_milestone: :environment do
    %i[val es].each do |locale|
      I18n.locale = locale
      %w[drafting processing execution executed].each do |state|
        Milestone::Status.find_or_create_by(
          name: I18n.t("budgets.milestone.statuses.#{state}"),
          description: I18n.t("budgets.milestone.statuses.#{state}_description")
        )
      end
    end
  end
end
