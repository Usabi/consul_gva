class CreateCitizenNewsletters < ActiveRecord::Migration[7.0]
  def change
    create_table :citizen_newsletters do |t|
      t.string :status, default: "pending"
      t.datetime :sent_at
      t.timestamps
    end

    add_index :citizen_newsletters, :status
    add_index :citizen_newsletters, :created_at

    create_table :citizen_newsletter_proposals do |t|
      t.references :citizen_newsletter, null: false, foreign_key: true,
                                        index: { name: "index_cnp_on_newsletter_id" }
      t.references :proposal, null: false, foreign_key: true

      t.timestamps
    end

    add_index :citizen_newsletter_proposals, [:citizen_newsletter_id, :proposal_id],
              unique: true, name: "index_cnp_on_newsletter_proposal"

    create_table :citizen_newsletter_debates do |t|
      t.references :citizen_newsletter, null: false, foreign_key: true,
                                        index: { name: "index_cnd_on_newsletter_id" }
      t.references :debate, null: false, foreign_key: true

      t.timestamps
    end

    add_index :citizen_newsletter_debates, [:citizen_newsletter_id, :debate_id],
              unique: true, name: "index_cnd_on_newsletter_debate"

    create_table :citizen_newsletter_preview_processes do |t|
      t.references :citizen_newsletter, null: false, foreign_key: true,
                                        index: { name: "index_cnpvp_on_newsletter_id" }
      t.references :process, null: false, foreign_key: { to_table: :legislation_processes }

      t.timestamps
    end

    add_index :citizen_newsletter_preview_processes, [:citizen_newsletter_id, :process_id],
              unique: true, name: "index_cnpvp_on_newsletter_preview_process"

    create_table :citizen_newsletter_public_processes do |t|
      t.references :citizen_newsletter, null: false, foreign_key: true,
                                        index: { name: "index_cnpp_on_newsletter_id" }
      t.references :process, null: false, foreign_key: { to_table: :legislation_processes }

      t.timestamps
    end

    add_index :citizen_newsletter_public_processes, [:citizen_newsletter_id, :process_id],
              unique: true, name: "index_cnpp_on_newsletter_public_process"
  end
end
