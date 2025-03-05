class CreateAlertMessages < ActiveRecord::Migration[4.2]
  def change
    create_table :alert_messages do |t|
      t.string   :target_url
      t.string   :flash_key
      t.boolean  :active
      t.datetime :hidden_at

      t.timestamps null: false
    end

    add_index :alert_messages, :hidden_at

    create_table   :alert_message_sections do |t|
      t.integer    :alert_message_id
      t.integer    :web_section_id
      t.timestamps null: false
    end

    create_table :alert_message_translations do |t|
      t.integer  :alert_message_id, null: false
      t.string   :locale, null: false
      t.string   :title,  limit: 80
      t.string   :description, limit: 150
      t.datetime :hidden_at

      t.timestamps null: false

      t.index :alert_message_id
      t.index :locale
      t.index :hidden_at
    end
  end
end
