load Rails.root.join("app", "lib", "application_logger.rb")

class ApplicationLogger
  def warn(message)
    logger.warn(message) unless Rails.env.test?
  end

  def error(message)
    logger.error(message) unless Rails.env.test?
  end
end
