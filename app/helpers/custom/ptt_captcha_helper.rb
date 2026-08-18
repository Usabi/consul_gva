module Custom::PttCaptchaHelper
  def ptt_captcha_enabled?
    @ptt_captcha_id.present?
  end

  def ptt_captcha_tags
    idioma = I18n.locale.to_s == "val" ? "va" : I18n.locale.to_s

    safe_join([
      content_tag(:div, "", data: { captcha_id: @ptt_captcha_id, captcha_idioma: idioma, captcha_posicio: "centrat" }),
      hidden_field_tag(:ptt_valor_captcha, "", id: "ptt_valor_captcha"),
      javascript_include_tag(PttCaptchaApi.front_js_url)
    ])
  end
end
