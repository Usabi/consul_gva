# frozen_string_literal: true

module Helpers
  def select_language(lang)
    within(".radio-toolbar") do
      find("label[for=local-#{lang}]").click
    end
  end

  def gvlogin_response_with_roles(role_values)
    role_payload =
      if role_values.is_a?(Array)
        { role: role_values.map do |rv|
          { codigo: "PARTICIPEM_CON",
            parametros: { parametro: { valorParametro: rv, nombreParametro: "ROL" }}}
        end }
      else
        { role: { codigo: "PARTICIPEM_CON",
                  parametros: { parametro: { valorParametro: role_values, nombreParametro: "ROL" }}}}
      end

    GvLoginApi::Response.new({
      resultado: true,
      datos: {
        mail: data.email,
        roles: role_payload,
        nombre: data.name,
        infoAmpliada: {
          parametro: [
            { valorParametro: data.codper, nombreParametro: "codper" }
          ]
        },
        dni: data.dni
      }
    }.to_json)
  end
end
