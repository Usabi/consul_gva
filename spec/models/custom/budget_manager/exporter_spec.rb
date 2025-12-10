require "rails_helper"

describe BudgetManager::Exporter do
  it_behaves_like "csv exporter",
                  :budget_manager,
                  BudgetManager::Exporter,
                  ["ID", "Username", "Email", "Description"]
end
