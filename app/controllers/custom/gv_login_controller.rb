class GvLoginController < ApplicationController

  skip_authorization_check :token

  # X_FORWARDED_FOR
  LOGIN_HOST = "http://gvlogin-dsa.gva.es".freeze

  LOGIN_WS = "gvlogin-ws".freeze

  def token
    @remote_ip = request.x_forwarded_for
    @GVLogin_cookie = cookies["gvlogin.login.GVLOGIN_COOKIE"]
    if @GVLogin_cookie
      client = Faraday.new(
        url: LOGIN_HOST,
        headers: {
                    'Content-Type': "application/json",
                    'Accept': "application/json"
                  }
      )
      body = {
        "aplicacion": "PARTICIPEM_GV",
        "tokenSSO": @GVLogin_cookie,
        "origen": {
            "ip": @remote_ip
        },
        "parametros": {
            "parametro": [
                {
                    "nombreParametro": "url",
                    "valorParametro": "https://gvaparticipa-dsa.gva.es/"
                }
            ]
        }
      }

      @response = client.post("/#{LOGIN_WS}/obtenerContexto", body.to_json)
      # @response = client.post("/verificarContexto", body.to_json)
      STDERR.puts cookies.to_h
      STDERR.puts @response
    else
      @response = "No ha llegado la cookie"
      STDERR.puts cookies.to_h
    end
  end
end
