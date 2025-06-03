namespace :middle_widget_card do
  desc "Create middle widget card"
  task create_cards: :environment do
    Globalize.with_locale(:val) do
      Widget::Card.find_or_create_by!(middle: true, label: "middle_left_val") do |card|
        card.title = "Secció central esquerra"
        card.link_url = "http://participem.gva.es/va/fase-1-informacio"
      end

      Widget::Card.find_or_create_by!(middle: true, label: "middle_right_val") do |card|
        card.title = "Secció central dreta"
        card.link_url = "http://participem.gva.es/va/fase-1-informacio"
      end
    end

    Globalize.with_locale(:es) do
      Widget::Card.find_or_create_by!(middle: true, label: "middle_left_es") do |card|
        card.title = "Sección central izquierda"
        card.link_url = "http://participem.gva.es/va/fase-1-informacio"
      end

      Widget::Card.find_or_create_by!(middle: true, label: "middle_right_es") do |card|
        card.title = "Sección central derecha"
        card.link_url = "http://participem.gva.es/va/fase-1-informacio"
      end
    end
  end
end
