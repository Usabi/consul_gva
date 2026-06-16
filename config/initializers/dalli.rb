if Rails.env.production?
  dalli_logger = Logger.new($stdout)
  dalli_logger.level = Logger::ERROR
  Dalli.logger = dalli_logger
end
