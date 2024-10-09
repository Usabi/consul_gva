class AddMilestoneStatusTranslations < ActiveRecord::Migration[6.1]
  def self.up
    I18n.locale = :es
    Milestone::Status.create_translation_table!(
      {
        name:        :string,
        description: :text
      },
      {
        migrate_data: true
      }
    )
  end

  def self.down
    Milestone::Status.drop_translation_table!
  end
end
