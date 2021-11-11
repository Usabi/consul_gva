require_dependency Rails.root.join("app", "models", "widget", "card").to_s

class Widget::Card
  translates :link_url, touch: true
  translates :link_text_2, touch: true
  translates :link_url_2, touch: true

  def self.body
    where(header: false, middle: false, site_customization_page_id: nil).order(:created_at)
  end

  def self.middle
    where(middle: true).order(:id)
  end
end
