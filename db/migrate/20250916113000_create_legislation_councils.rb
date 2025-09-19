class CreateLegislationCouncils < ActiveRecord::Migration[4.2]
  def change
    create_table :legislation_councils do |t|
      t.string   "title", limit: 80
      t.boolean  "active", default: true
      t.datetime "hidden_at"

      t.timestamps null: false
      t.index :hidden_at
    end
  end
end
