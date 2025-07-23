class WYSIWYGSanitizerNewsletter
  def allowed_tags
    %w[p ul ol li strong em u s a h2 h3 h4 br table tbody tr td span]
  end

  def allowed_attributes
    %w[href style cellpadding cellspacing border]
  end

  def sanitize(html)
    ActionController::Base.helpers.sanitize(html, tags: allowed_tags, attributes: allowed_attributes)
  end
end
