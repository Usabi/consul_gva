class GvLoginController < ApplicationController

  skip_authorization_check :token

  URL = "http://gvlogin-dsa.gva.es/gvlogin-ws/".freeze

  def token
    if !cookies["gvlogin.login.GVLOGIN_COOKIE"]
      client = Faraday.new(
        url: URL,
        headers: { 'Content-Type': "application/json" }
      )
      body = {
        "tokenSSO": cookies["gvlogin.login.GVLOGIN_COOKIE"],
        "origen": {
          "ip": request.ip
        }
      }
      @response = client.post("/verificarContexto", body.to_json)
      STDERR.puts cookies.to_h
      STDERR.puts @response
    else
      @response = "No ha llegado la cookie"
      STDERR.puts cookies.to_h
    end
  end
end
