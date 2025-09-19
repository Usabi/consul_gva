class AddCouncilTranslations < ActiveRecord::Migration[6.1]
  def self.up
    I18n.locale = :es
    create_table :legislation_council_translations do |t|
      t.references :legislation_council, null: false, foreign_key: { to_table: :legislation_councils }, index: false
      t.string :title
      t.string :locale, null: false
      t.datetime :hidden_at, index: true
      t.timestamps
    end

    add_index :legislation_council_translations,
              [:legislation_council_id, :locale],
              name: 'idx_leg_pr_council_translations'
  end

  def self.down
    drop_table :legislation_council_translations
  end
end
