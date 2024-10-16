
require_dependency Rails.root.join("app", "controllers", "concerns", "admin", "widget", "cards_actions").to_s

module Admin::Widget::CardsActions
  private

    def allowed_params
      [
        :link_url, :button_text, :button_url, :alignment, :header, :columns, :middle,
        translation_params(Widget::Card),
        image_attributes: image_attributes
      ]
    end
end
