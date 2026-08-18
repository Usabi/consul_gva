require "net/http"
require "json"

class PttCaptchaApi
  BASE_PRE  = "https://innovacion-pre.gva.es/pai_bus_inno/CAPTCHA/CAPTCHA_REST_v1_00"
  BASE_PROD = "https://innovacion.gva.es/pai_bus_inno/CAPTCHA/CAPTCHA_REST_v1_00"

  def self.create_captcha
    response = post("/crear", { appId: app_id, nivel: "F" })
    response["idCaptcha"]
  end

  def self.validate_captcha(id_captcha, valor_captcha)
    response = post("/validar", { idCaptcha: id_captcha, valorCaptcha: valor_captcha.to_s })
    response["valido"].to_s == "true"
  end

  def self.front_js_url
    if Rails.env.production?
      "https://ptt-captcha-front.gva.es/ptt-captcha-front/js/ptt-captcha.js"
    else
      "https://ptt-captcha-front-pre.gva.es/ptt-captcha-front/js/ptt-captcha.js"
    end
  end

  private_class_method def self.post(path, body)
    uri = URI("#{base_url}#{path}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 5
    http.read_timeout = 10

    request = Net::HTTP::Post.new(uri.path)
    request["Content-Type"] = "application/json"
    request["x-api-key"]    = x_api_key
    request["aplicacion"]   = aplicacion

    request.body = body.to_json
    response = http.request(request)
    parsed = JSON.parse(response.body)

    handle_error(response.code, parsed, path)

    parsed
  rescue Net::OpenTimeout, Net::ReadTimeout => e
    Rails.logger.error("PttCaptchaApi timeout [#{path}]: #{e.message}")
    {}
  rescue StandardError => e
    Rails.logger.error("PttCaptchaApi error [#{path}]: #{e.message}")
    {}
  end

  private_class_method def self.handle_error(http_code, parsed, path)
    # Error de negocio PAI: {"errorMessage": "[0301]Organismo no autorizado"}
    if parsed["errorMessage"].present?
      code = parsed["errorMessage"][/\[(\d{4})\]/, 1]
      description = I18n.t("ptt_captcha_api.business_errors.#{code}",
                            locale: :es, default: parsed["errorMessage"])
      Rails.logger.error("PttCaptchaApi [#{path}] error PAI #{code}: #{description}")
      return
    end

    # Error HTTP genérico
    unless http_code == "200"
      description = I18n.t("ptt_captcha_api.http_errors.#{http_code}",
                            locale: :es, default: I18n.t("ptt_captcha_api.unknown_error", locale: :es))
      Rails.logger.error("PttCaptchaApi [#{path}] HTTP #{http_code}: #{description}")
    end
  end

  private_class_method def self.base_url
    Rails.env.production? ? BASE_PROD : BASE_PRE
  end

  private_class_method def self.app_id
    PttCaptcha.configuration.app_id
  end

  private_class_method def self.x_api_key
    PttCaptcha.configuration.x_api_key
  end

  private_class_method def self.aplicacion
    PttCaptcha.configuration.aplicacion
  end
end
