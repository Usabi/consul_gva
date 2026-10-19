require "rails_helper"

describe PttCaptcha do
  around do |example|
    original = described_class.configuration.dup
    example.run
  ensure
    described_class.configuration = original
  end

  describe ".configure" do
    it "yields a configuration object and persists the assigned values" do
      described_class.configure do |config|
        config.app_id = "APP-ID"
        config.x_api_key = "X-API-KEY"
        config.aplicacion = "APLICACION"
        config.base_url = "https://example.test/CAPTCHA_REST_v1_00"
        config.front_js_url = "https://example.test/ptt-captcha.js"
      end

      expect(described_class.configuration.app_id).to eq("APP-ID")
      expect(described_class.configuration.x_api_key).to eq("X-API-KEY")
      expect(described_class.configuration.aplicacion).to eq("APLICACION")
      expect(described_class.configuration.base_url).to eq("https://example.test/CAPTCHA_REST_v1_00")
      expect(described_class.configuration.front_js_url).to eq("https://example.test/ptt-captcha.js")
    end
  end

  describe ".configuration" do
    it "memoizes the same instance across calls" do
      expect(described_class.configuration).to equal(described_class.configuration)
    end

    it "is loaded from secrets.yml by the initializer" do
      expect(described_class.configuration.app_id).to eq(Rails.application.secrets.ptt_app_id)
      expect(described_class.configuration.x_api_key).to eq(Rails.application.secrets.ptt_x_api_key)
      expect(described_class.configuration.aplicacion).to eq(Rails.application.secrets.ptt_aplicacion)
      expect(described_class.configuration.base_url).to eq(Rails.application.secrets.ptt_base_url)
      expect(described_class.configuration.front_js_url).to eq(Rails.application.secrets.ptt_front_js_url)
    end

    context "when app_id has a value" do
      before { described_class.configure { |config| config.app_id = "APP-ID" } }

      it "is present" do
        expect(described_class.configuration.app_id).to be_present
      end
    end

    context "when app_id is blank" do
      before { described_class.configure { |config| config.app_id = "" } }

      it "is not present" do
        expect(described_class.configuration.app_id).not_to be_present
      end
    end

    context "when app_id was never set" do
      before { described_class.configuration = described_class::Configuration.new }

      it "is nil" do
        expect(described_class.configuration.app_id).to be_nil
      end

      it "is not present" do
        expect(described_class.configuration.app_id).not_to be_present
      end
    end
  end
end
