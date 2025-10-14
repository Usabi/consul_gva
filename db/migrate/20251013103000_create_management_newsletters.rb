class CreateManagementNewsletters < ActiveRecord::Migration[6.0]
  def change
    create_table :management_newsletters do |t|
      t.string :status, default: "pending"
      t.datetime :sent_at
      t.timestamps
    end

    add_index :management_newsletters, :status
    add_index :management_newsletters, :created_at

    create_table :management_newsletter_proposals do |t|
      t.references :management_newsletter, null: false, foreign_key: true,
                                           index: { name: "index_mnp_on_newsletter_id" }
      t.references :proposal, null: false, foreign_key: true

      t.timestamps
    end

    add_index :management_newsletter_proposals, [:management_newsletter_id, :proposal_id],
              unique: true, name: "index_mnp_on_newsletter_proposal"

    create_table :management_newsletter_debates do |t|
      t.references :management_newsletter, null: false, foreign_key: true,
                                           index: { name: "index_mnd_on_newsletter_id" }
      t.references :debate, null: false, foreign_key: true

      t.timestamps
    end

    add_index :management_newsletter_debates, [:management_newsletter_id, :debate_id],
              unique: true, name: "index_mnd_on_newsletter_debate"

    create_table :management_newsletter_preview_processes do |t|
      t.references :management_newsletter, null: false, foreign_key: true,
                                           index: { name: "index_mnpvp_on_newsletter_id" }
      t.references :process, null: false, foreign_key: { to_table: :legislation_processes }

      t.timestamps
    end

    add_index :management_newsletter_preview_processes, [:management_newsletter_id, :process_id],
              unique: true, name: "index_mnpvp_on_newsletter_preview_process"

    create_table :management_newsletter_public_processes do |t|
      t.references :management_newsletter, null: false, foreign_key: true,
                                           index: { name: "index_mnpp_on_newsletter_id" }
      t.references :process, null: false, foreign_key: { to_table: :legislation_processes }

      t.timestamps
    end

    add_index :management_newsletter_public_processes, [:management_newsletter_id, :process_id],
              unique: true, name: "index_mnpp_on_newsletter_public_process"
  end
end
