require "json"

require_dependency Rails.root.join("lib", "census_api").to_s

class CensusApi
  def call(document_type, document_number, other_data = {})
    response = Response.new(get_response_body(document_type, document_number, other_data))
    ApplicationLogger.new.warn "data (#{document_number}): #{response.data}"
    response
  end

  class Response
    def datos_vivienda?
      data[:datos_vivienda]["resultado"]
    end

    def datos_vivienda_error
      unless datos_vivienda?
        unless data[:datos_vivienda]["error"]
          return :error_0233 if data[:datos_vivienda]["estado"] =~ /^0233/ #"Titular no Identificado o Ámbito Territorial de Residencia Incorrecto"
          return :error_4 if data[:datos_vivienda]["estado"] =~ /^4/ #"Ámbito Territorial Residencia Incorrecto"
        else
          return :error_0231 if data[:datos_vivienda]["error"] =~ /^0231/ #Se ha recibido una petición en la que la validación del NIFTitular es incorrecta
        end
      end
    end

    def datos_habitante?
      data[:datos_habitante]["resultado"]
    end

    def datos_habitante_error
      unless datos_habitante?
        unless data[:datos_habitante]["error"]
          return :error if data[:datos_habitante]["estado"]
        else
          return :error_0231 if data[:datos_habitante]["error"] =~ /^0231/ #Se ha recibido una petición en la que la validación del NIFTitular es incorrecta
        end
      end
    end

    def valid?
      return false if data =~ /^ERROR/

      datos_vivienda? && datos_habitante?
    end

    def error
      return data if data =~ /^ERROR/

      error = !datos_vivienda? && data[:datos_vivienda]["error"] ||
      !datos_habitante? && data[:datos_habitante]["error"]

      data[:datos_vivienda]["estado"] =~ /^0233/ ? "No residente" : error
    end

    def date_of_birth
      str = data[:datos_habitante]["fecha_nacimiento"]
      return nil if str.blank?

      year, month, day = str.match(/(\d\d\d\d)(\d\d)(\d\d)/)[1..3]
      return nil unless day.present? && month.present? && year.present?

      Time.zone.local(year.to_i, month.to_i, day.to_i).to_date
    end

    def postal_code
      data[:datos_originales][:postal_code] # Devolvemos el dato entrado porque el servicio sólo comprueba residencia, no devuelve datos
    end

    def district_code
      data[:datos_originales][:postal_code][0..1] # Devolvemos el dato entrado porque el servicio sólo comprueba residencia, no devuelve datos
    end

    def gender
      case data[:datos_habitante]["sexo"]
      when "V" # H
        "male"
      when "M"
        "female"
      end
    end

    def data
      @body
    end
  end

  class ConnectionCensus
    def call(document_type, document_number, other_data = {})
      @postal_code = other_data[:postal_code]
      @name = other_data[:name]
      @first_surname = other_data[:first_surname]
      @last_surname = other_data[:last_surname]

      age_response = get_age(document_type, document_number)
      residence_response = get_residence(document_type, document_number)

      # we return the script error if some
      return age_response if age_response =~ /^ERROR/
      return residence_response if residence_response =~ /^ERROR/

      {
        datos_habitante: JSON.parse(age_response),
        datos_vivienda: JSON.parse(residence_response),
        datos_originales: other_data
      }
    end

    private

    def get_age(document_type, document_number)
      logger.warn "--- #{Time.now.iso8601} inicio verificación edad (DGP) ---"
      validator = Rails.application.secrets.census_api_age_validator
      logger.warn "Age validator path: #{validator}"
      logger.warn "Document type: #{document_type}"
      logger.warn "php -f #{validator} -- -i #{identifier} -n #{document_number} -o \"#{@name}\" -a \"#{@first_surname}\" -p \"#{@last_surname}\" #{'--esp n' if document_type == '4'}"
      result = `php -f #{validator} -- -i #{identifier} -n #{document_number} -o "#{@name}" -a "#{@first_surname}" -p "#{@last_surname}" #{'--esp n' if document_type == '4'}`
      logger.warn "result (#{document_number}): #{result}"
      logger.warn "--- #{Time.now.iso8601} fin verificación edad (DGP) ---"
      result
    end

    def get_residence(document_type, document_number)
      logger.warn "--- #{Time.now.iso8601} inicio verificación residencia (INE) ---"
      validator = Rails.application.secrets.census_api_residence_validator
      logger.warn "Residence validator path: #{validator}"
      # La persona de pruebas en servicio de residencia es diferente que en el servicio de edad
      # Cambiamos los valores aquí para que en caso de que llegue del formulario el de prueba, aquí ponga los datos necesarios.
      logger.warn "environment: #{Rails.application.secrets.environment}"
      # Comentamos mientras el servicio del INE en producción no esté activado (ahora mismo sólo detecta si es código correcto)
      #  if Rails.application.secrets.environment != 'production' && document_number.upcase == '10000320N'
      #    document_number = '10000322Z'
      #    province_code = '17'
      #  else
      province_code = @postal_code[0..1]
      #  end
      logger.warn "province_code: #{province_code}"
      logger.warn "php -f #{validator} -- -i #{identifier} -n #{document_number} -p #{province_code} --esp #{document_type == '4' ? 'n' : 's'}"
      result = `php -f #{validator} -- -i #{identifier} -n #{document_number} -p #{province_code} --esp #{document_type == '4' ? 'n' : 's'}`
      logger.warn "result (#{document_number}): #{result}"
      logger.warn "--- #{Time.now.iso8601} fin verificación residencia (INE) ---"
      result
    end

    def identifier
      Time.now.to_i.to_s[-7..-1]
    end

    def logger
      @logger ||= ApplicationLogger.new
    end
  end

  private

    def get_response_body(document_type, document_number, other_data = {})
      if end_point_available?
        client.call(document_type, document_number, other_data)
      else
        stubbed_response(document_type, document_number)
      end
    end

    def client
      @client = ConnectionCensus.new
    end

    def end_point_defined?
      Rails.application.secrets.census_api_age_validator.present? &&
        Rails.application.secrets.census_api_residence_validator.present?
    end

    def end_point_available?
      (Rails.env.staging? || Rails.env.preproduction? || Rails.env.production?) && end_point_defined?
    end

    def stubbed_response(document_type, document_number)
      if (document_number == "12345678Z" || document_number == "12345678Y") && document_type == "1"
        stubbed_valid_response
      else
        stubbed_invalid_response
      end
    end

    def stubbed_valid_response
      # values from php scripts test data
      {
        datos_habitante: {
          "resultado" => true,
          "error" => false,
          "cod_estado" => "00",
          "literal_error" => "INFORMACION CORRECTA",
          "nacionalidad" => "ESPA\u00d1A-ESP",
          "sexo" => "F",
          "fecha_nacimiento" => "20030518"
        },
        datos_vivienda: {
          "resultado" => true,
          "error" => false,
          "estado" => "003",
          "literal" => "Verificaci\u00f3n positiva. \u00c1mbito Territorial de Residencia Correcto."
        },
        datos_originales: {
          postal_code: "46001",
          name: "NAME",
          first_surname: "FIRST SURNAME",
          last_surname: "LAST SURNAME"
        }
      }
    end
    # Invalid
    def stubbed_invalid_response
      {
        datos_habitante: {
          "resultado" => false,
          "error" => false,
          "estado" => "0233",
          "literal" => "Titular no Identificado o \u00c1mbito Territorial de Residencia Incorrecto"
        },
        datos_vivienda: {
          "resultado" => false,
          "error" => "0231 Documento incorrecto"
        },
        datos_originales: {
          postal_code: "46001",
          name: "NAME",
          first_surname: "FIRST SURNAME",
          last_surname: "LAST SURNAME",
          date_of_birth: 25.years.ago.to_date
        }
      }
    end

    def stubbed_invalid_postal_code_response
      {
        datos_habitante: {
          "resultado" => true,
          "error" => false,
          "cod_estado" => "00",
          "literal_error" => "INFORMACION CORRECTA",
          "nacionalidad" => "ESPA\u00d1A-ESP",
          "sexo" => "F",
          "fecha_nacimiento" => "20030518"
        },
        datos_vivienda: {
          "resultado" => false,
          "error" => "0231 Documento incorrecto"
          # "error" => false,
          # "estado" => "4",
          # "estado" => "0233",
          # "literal" => "Ãmbito Territorial de Residencia Incorrecto"
        },
        datos_originales: {
          postal_code: "46001",
          name: "NAME",
          first_surname: "FIRST SURNAME",
          last_surname: "LAST SURNAME",
          date_of_birth: 25.years.ago.to_date
        }
      }
    end

    def stubbed_invalid_postal_code_and_document_number_response
      {
        datos_habitante: {
          "resultado" => true,
          "error" => " Documento incorrecto",
          # "error" => false,
          # "estado" => "0233",
          "literal" => "Titular no Identificado o \u00c1mbito Territorial de Residencia Incorrecto"
        },
        datos_vivienda: {
          "resultado" => true,
          # "error" => "0231 Documento incorrecto"
          "error" => false,
          # "estado" => "4",
          # "estado" => "0233",
          # "literal" => "Ãmbito Territorial de Residencia Incorrecto"
        },
        datos_originales: {
          postal_code: "46001",
          name: "NAME",
          first_surname: "FIRST SURNAME",
          last_surname: "LAST SURNAME",
          date_of_birth: 25.years.ago.to_date
        }
      }
    end

    def logger
      @logger ||= ApplicationLogger.new
    end
end
