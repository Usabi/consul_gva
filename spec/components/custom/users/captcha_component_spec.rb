require "rails_helper"

describe Users::CaptchaComponent do
  def set_session_captcha_id(id)
    vc_test_request.session[:ptt_captcha_id] = id
  end

  describe "rendering" do
    it "renders nothing when neither PTT nor Google are configured" do
      allow(Rails.application.secrets).to receive(:site_key).and_return("")
      allow(Rails.application.secrets).to receive(:secret_key).and_return("")

      render_inline described_class.new

      expect(rendered_content.to_s.strip).to be_empty
    end

    context "with a PTT captcha id in session" do
      before { set_session_captcha_id("TEST-CAPTCHA-ID") }

      it "renders the PTT widget with the captcha id" do
        render_inline described_class.new

        expect(page).to have_css("[data-captcha-id='TEST-CAPTCHA-ID']")
      end

      it "renders the hidden field for the captcha value" do
        render_inline described_class.new

        expect(page).to have_css("input#ptt_valor_captcha[type='hidden']", visible: :all)
      end

      it "includes the PTT front-end script" do
        render_inline described_class.new

        expect(page).to have_css("script[src='#{PttCaptchaApi.front_js_url}']", visible: :all)
      end

      it "maps the val locale to va for the widget" do
        I18n.with_locale(:val) do
          render_inline described_class.new
        end

        expect(page).to have_css("[data-captcha-idioma='va']")
      end

      it "does not render the Google widget even if it's configured" do
        allow(Rails.application.secrets).to receive(:site_key).and_return("SITE-KEY")
        allow(Rails.application.secrets).to receive(:secret_key).and_return("SECRET-KEY")

        render_inline described_class.new

        expect(page).to have_no_css(".g-recaptcha")
      end
    end

    context "without a PTT captcha id but with Google secrets configured" do
      before do
        allow(Rails.application.secrets).to receive(:site_key).and_return("SITE-KEY")
        allow(Rails.application.secrets).to receive(:secret_key).and_return("SECRET-KEY")
      end

      it "renders the Google reCAPTCHA widget" do
        render_inline described_class.new

        expect(page).to have_css(".g-recaptcha")
      end

      it "does not render the PTT widget" do
        render_inline described_class.new

        expect(page).to have_no_css("[data-captcha-id]")
      end
    end
  end
end
