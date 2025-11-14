class AddNewsletterPreferencesToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :newsletter_debates, :boolean, default: false
    add_column :users, :newsletter_proposals, :boolean, default: false
    add_column :users, :newsletter_legislation, :boolean, default: false
  end
end
