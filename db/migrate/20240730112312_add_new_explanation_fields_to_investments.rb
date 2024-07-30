class AddNewExplanationFieldsToInvestments < ActiveRecord::Migration[6.1]
  def change
    add_column :budget_investments, :next_year_budget_explanation, :text
    add_column :budget_investments, :next_year_budget_email_sent_at, :datetime
    add_column :budget_investments, :takecharge_explanation, :text
    add_column :budget_investments, :takecharge_email_sent_at, :datetime
  end
end
