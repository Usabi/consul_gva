class CreateCitizenOpinions < ActiveRecord::Migration[6.1]
  def change
    create_table :citizen_opinions do |t|
      t.string :topic, null: false
      t.string :name
      t.string :phone
      t.string :subject
      t.text :body, null: false
      t.string :email, null: false

      t.timestamps
    end
  end
end
