class CreateBulletins < ActiveRecord::Migration[4.2]
  def change
    create_table :bulletins do |t|
      t.string   :title, null: false
      t.string   :template, null: false
      t.jsonb    :sent_at_dates, default: []

      t.timestamps null: false
    end
  end
end
