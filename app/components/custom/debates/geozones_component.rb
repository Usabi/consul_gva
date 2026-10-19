class Debates::GeozonesComponent < ApplicationComponent
  delegate :image_path_for, to: :helpers

  def render?
    Geozone.any?
  end
end
