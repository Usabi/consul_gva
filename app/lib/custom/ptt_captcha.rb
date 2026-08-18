module PttCaptcha
  class Configuration
    attr_accessor :app_id, :x_api_key, :aplicacion
  end

  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end
