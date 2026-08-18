require "rails_helper"

describe Custom::PttCaptchaHelper do
  describe "#ptt_captcha_enabled?" do
    it "is true when @ptt_captcha_id is present" do
      assign(:ptt_captcha_id, "TEST-ID")
      expect(helper.ptt_captcha_enabled?).to be true
    end

    it "is false when @ptt_captcha_id is blank" do
      assign(:ptt_captcha_id, nil)
      expect(helper.ptt_captcha_enabled?).to be false
    end
  end

  describe "#ptt_captcha_tags" do
    before { assign(:ptt_captcha_id, "TEST-ID") }

    it "renders the captcha widget with the current captcha id" do
      expect(helper.ptt_captcha_tags).to include('data-captcha-id="TEST-ID"')
    end

    it "renders the hidden field for the captcha value" do
      expect(helper.ptt_captcha_tags).to include('id="ptt_valor_captcha"')
      expect(helper.ptt_captcha_tags).to include('type="hidden"')
    end

    it "includes the PTT front-end script" do
      expect(helper.ptt_captcha_tags).to include(PttCaptchaApi.front_js_url)
    end

    it "maps the val locale to va for the widget" do
      I18n.with_locale(:val) do
        expect(helper.ptt_captcha_tags).to include('data-captcha-idioma="va"')
      end
    end

    it "uses the locale directly for other locales" do
      I18n.with_locale(:es) do
        expect(helper.ptt_captcha_tags).to include('data-captcha-idioma="es"')
      end
    end
  end
end
