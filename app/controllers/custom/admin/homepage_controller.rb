load Rails.root.join("app", "controllers", "admin", "homepage_controller.rb")

class Admin::HomepageController
  def show
    load_header
    load_middle
    load_feeds
    load_recommendations
    load_cards
  end

  private

    def load_middle
      @middle = ::Widget::Card.middle
    end
end
