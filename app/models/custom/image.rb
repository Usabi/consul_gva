require_dependency Rails.root.join("app", "models", "image").to_s

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
