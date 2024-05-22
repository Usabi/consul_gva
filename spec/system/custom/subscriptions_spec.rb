require "rails_helper"

describe "Subscriptions" do
  let(:user) { create(:user, subscriptions_token: SecureRandom.base58(32)) }

  context "Edit page" do
    scenario "Render content in the user's preferred locale" do
      user.update!(locale: "es")
      visit edit_subscriptions_path(token: user.subscriptions_token)

      expect(page).to have_content "Notificaciones"
      expect(page).to have_field "Recibir un email cuando alguien comenta en mis contenidos", type: :checkbox
      expect(page).to have_field "Recibir un email cuando alguien contesta a mis comentarios", type: :checkbox
      expect(page).to have_field "Recibir emails con información interesante sobre la web", type: :checkbox
      expect(page).to have_field "Recibir resumen de notificaciones sobre iniciativas", type: :checkbox
      expect(page).to have_field "Recibir emails con mensajes privados", type: :checkbox
      expect(page).to have_button "Guardar cambios"
    end
  end
end
