class CreateLegislationProcessLegislators < ActiveRecord::Migration[5.2]
  def change
    create_table :legislation_process_legislators do |t|
      t.references :legislation_process, foreign_key: true
      t.references :legislator, foreign_key: true
      t.timestamps
    end
  end
end
