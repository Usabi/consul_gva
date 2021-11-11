class GVLoginApi
  #tab_panel_id:tab_panel_login_user_pass_LDAPGva_id
  GVLOGIN_HOSTS = {
       gvaparticipa_dsa: "http://gvlogin-dsa.gva.es",
       gvaparticipa_pre: "http://gvlogin-pre.gva.es",
       gvaparticipa: "http://gvlogin.gva.es",
       localhost: "http://gvlogin-dsa.gva.es"
  }.freeze

  def initialize(host)
    @host = host.freeze
    @webservice_login = webservice(host).freeze
    @web_gv_login = "#{@webservice_login}/gvlogin/login.xhtml?app=participem_gv&url=https://#{host == "localhost" ? "gvaparticipa-dsa.gva.es" : host}/login_token".freeze
  end

  class ConnectionGVLogin
    def call(url)
      Faraday.new(
        url: url,
        headers: {
                    'Content-Type': "application/json",
                    'Accept': "application/json"
                  }
      )
    end
  end

  class Response
    def initialize(body)
      @body = JSON.parse(body).with_indifferent_access
    end

    def valid?
      @body[:resultado]
    end

    def errors
      unless valid?
        to_struct(@body[:error]).mensaje_error
      else
        "No hay errores"
      end
    end

    def data
      if valid?
        to_struct(@body[:datos])
      else
        errors
      end
    end

    private

      def to_struct(json_object)
        new_object = json_object.keys.reduce({}) do |hash, key|
          unless key.to_s == "infoAmpliada"
            hash[key.to_s.underscore] = json_object[key]
          else
            if key.to_s == "infoAmpliada"
              hash[key.to_s.underscore] = json_object[key][:parametro].reduce({}) do |parameter_hash, parameter|
                parameter_hash[parameter[:nombreParametro].to_s.underscore] = parameter[:valorParametro]
                parameter_hash
              end
            end
          end
          hash
        end
        OpenStruct.new new_object
      end
  end

  def context(ip, cookie)
    get_context_response(ip, cookie)
  end

  def web_gv_login
    @web_gv_login
  end

  private

    def get_context(type_context, body)
      response = client.post("/gvlogin-ws/#{type_context}", body.to_json)
      Response.new response.body
    end

    def get_context_response(ip, cookie)
      verificar_body = {
        "tokenSSO": cookie,
        "origen": {
            "ip": ip
        }
      }

      obtener_body = {
        "aplicacion": "PARTICIPEM_GV",
        "tokenSSO": cookie,
        "origen": {
            "ip": ip
        },
        "parametros": {
            "parametro": [
                {
                  "nombreParametro": "url",
                  "valorParametro": "https://#{@host == "localhost" ? "gvaparticipa-dsa.gva.es" : @host}"
                }
            ]
        }
      }
      if get_context("verificarContexto", verificar_body).valid?
        get_context("obtenerContexto", obtener_body)
      else
        get_context("verificarContexto", verificar_body)
      end
    end

    def client
      ConnectionGVLogin.new.call @webservice_login
    end

    def webservice(host)
      host_name = host.underscore.split(".").first.to_sym
      GVLOGIN_HOSTS[host_name]
    end
 end
