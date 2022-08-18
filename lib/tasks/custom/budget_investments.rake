namespace :budget_investments do
  desc "Set investments winners"
  task set_winners: :environment do
    ApplicationLogger.new.info "Set investments winners"
    if Rails.application.secrets.environment == "production"
      ## Production
      # 83  -> Adquisició i reforma del Real Monestir de Santa Maria D’Aigües Vives
      # 740 -> Recuperación Masías del interior
      ids = [83, 740]
      Budget::Investment.where(id: ids).update_all(winner: true)
    end
  end
end
