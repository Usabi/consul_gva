require "rails_helper"

describe "rake ptt_captcha:verify" do
  let(:logger) { instance_double(ApplicationLogger, info: nil, warn: nil) }
  let(:messages) do
    [].tap do |collected|
      allow(logger).to receive(:info) { |message| collected << message.to_s }
      allow(logger).to receive(:warn) { |message| collected << message.to_s }
    end
  end

  before do
    Rake::Task["ptt_captcha:verify"].reenable
    allow(ApplicationLogger).to receive(:new).and_return(logger)
    allow(PttCaptcha.configuration).to receive_messages(app_id: "SECRET-APP-ID", x_api_key: "SECRET-API-KEY",
                                                        aplicacion: "SECRET-APLICACION")
    allow(PttCaptchaApi).to receive(:create_captcha).and_return("CAPTCHA-ID")
  end

  def run_task
    messages
    Rake.application.invoke_task("ptt_captcha:verify")
    messages
  end

  it "logs which PTT keys are present without exposing their values" do
    output = run_task.join("\n")

    expect(output).to include("PTT app_id present: true")
    expect(output).to include("PTT x_api_key present: true")
    expect(output).to include("PTT aplicacion present: true")
    expect(output).not_to include("SECRET-APP-ID")
    expect(output).not_to include("SECRET-API-KEY")
    expect(output).not_to include("SECRET-APLICACION")
  end

  it "logs the Rails environment and the PTT endpoint used" do
    output = run_task.join("\n")

    expect(output).to include("Rails env: test")
    expect(output).to include("PTT endpoint: #{PttCaptchaApi.base_url}")
  end

  it "reports PTT as the captcha in use when a captcha can be created" do
    output = run_task.join("\n")

    expect(output).to include("PTT create_captcha: OK")
    expect(output).to include("Captcha in use: PTT")
  end

  context "when the PTT keys are blank" do
    before do
      allow(PttCaptcha.configuration).to receive_messages(app_id: "", x_api_key: nil, aplicacion: nil)
    end

    it "reports the keys as missing and does not call the PTT API" do
      output = run_task.join("\n")

      expect(output).to include("PTT app_id present: false")
      expect(output).to include("PTT x_api_key present: false")
      expect(output).to include("PTT aplicacion present: false")
      expect(output).to include("PTT create_captcha: SKIPPED")
      expect(PttCaptchaApi).not_to have_received(:create_captcha)
    end

    it "reports Google when the recaptcha keys exist" do
      allow(Rails.application.secrets).to receive_messages(site_key: "site", secret_key: "secret")

      expect(run_task.join("\n")).to include("Captcha in use: Google reCAPTCHA")
    end

    it "reports none when there are no recaptcha keys either" do
      allow(Rails.application.secrets).to receive_messages(site_key: nil, secret_key: nil)

      expect(run_task.join("\n")).to include("Captcha in use: none")
    end
  end

  context "when the PTT API does not return a captcha" do
    before { allow(PttCaptchaApi).to receive(:create_captcha).and_return(nil) }

    it "warns that the form falls back to Google and points to the application log" do
      allow(Rails.application.secrets).to receive_messages(site_key: "site", secret_key: "secret")

      output = run_task.join("\n")

      expect(output).to include("PTT create_captcha: FAILED")
      expect(output).to include("Captcha in use: Google reCAPTCHA (PTT unavailable)")
      expect(output).to include("PttCaptchaApi")
    end
  end
end
