class AddMiddleToCards < ActiveRecord::Migration[5.1]
  class Widget::Card < ApplicationRecord;
    self.table_name = 'widget_cards'
    translates :label,       touch: true
    translates :title,       touch: true
    translates :description, touch: true
    translates :link_text,   touch: true
    translates :link_url,    touch: true
    translates :link_text_2, touch: true
    translates :link_url_2,  touch: true
    include Imageable
    include Globalizable
  end

  def up
    add_column :widget_cards, :middle, :boolean, default: false

    # Widget::Card.reset_column_information
    # Widget::Card.create!(
    #   middle: true,
    #   label_val: 'middle_left_val',
    #   title_val: 'Secció central esquerra',
    #   link_text_val: 'Informació i debats',
    #   link_url_val: 'http://participem.gva.es/va/fase-1-informacio',
    #   link_text_2_val: 'Dona Suport a la teua proposta! ',
    #   link_url_2_val: 'https://gvaparticipa.gva.es/budgets',
    #   image_attributes: create_image_attachment(:val, :text)
    # )
    # Widget::Card.create!(
    #   middle: true,
    #   label_val: 'middle_right_val',
    #   title_val: 'Secció central dreta',
    #   image_attributes: create_image_attachment(:val, :image),
    # )

    # Widget::Card.create!(
    #   middle: true,
    #   label_es: 'middle_left_es',
    #   title_es: 'Sección central izquierda',
    #   link_text_es: 'Información y debates',
    #   link_url_es: 'http://participem.gva.es/es/fase-1-informacio',
    #   link_text_2_es: '¡Apoya tu propuesta!',
    #   link_url_2_es: 'https://gvaparticipa.gva.es/budgets',
    #   image_attributes: create_image_attachment(:es, :text)
    # )
    # Widget::Card.create!(
    #   middle: true,
    #   label_es: 'middle_right_es',
    #   title_es: 'Sección central derecha',
    #   image_attributes: create_image_attachment(:es, :image),
    # )
  end

  def down
    Widget::Card.where(middle: true).destroy_all
    remove_column :widget_cards, :middle
  end

  def create_image_attachment(lang, type)
    {
      cached_attachment: Rails.root.join("app/assets/images/custom/welcome/#{lang}/#{type}.png"),
      title: "#{type}_background.png",
      user: User.first
    }
  end
end
