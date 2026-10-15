class CreateFooterLinks < ActiveRecord::Migration[7.0]
  def change
    create_table :footer_links do |t|
      t.string  :url, null: false
      t.integer :position, null: false, default: 0
      t.boolean :visible, null: false, default: true

      t.timestamps null: false
    end

    add_index :footer_links, [:visible, :position]

    reversible do |dir|
      dir.up do
        FooterLink.create_translation_table!({ label: { type: :string, limit: 80 }})
      end

      dir.down do
        FooterLink.drop_translation_table!
      end
    end
  end
end
