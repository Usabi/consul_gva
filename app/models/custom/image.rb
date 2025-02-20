load Rails.root.join("app", "models", "image.rb")

class Image
  def variant(style)
    return "" unless attachment.attached?

    if style
      attachment.variant(self.class.styles[style])
    else
      attachment
    end
  end
end
