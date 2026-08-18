require "rails_helper"

describe PttCaptchaApi do
  let(:captcha_id) { "CEJWBDAZ-A0BFGDT8-T8SWQARC" }

  before do
    allow(Rails.application.secrets).to receive(:ptt_app_id).and_return("TEST-APP")
    allow(Rails.application.secrets).to receive(:ptt_x_api_key).and_return("test-x-api-key")
    allow(Rails.application.secrets).to receive(:ptt_aplicacion).and_return("test-aplicacion")
  end

  let(:http_double) do
    instance_double(Net::HTTP).tap do |h|
      allow(h).to receive(:use_ssl=)
      allow(h).to receive(:open_timeout=)
      allow(h).to receive(:read_timeout=)
    end
  end

  before do
    allow(Net::HTTP).to receive(:new).and_return(http_double)
  end

  def stub_http(body:, code: "200")
    response = instance_double(Net::HTTPResponse, code: code, body: body.to_json)
    allow(http_double).to receive(:request).and_return(response)
    response
  end

  describe ".crear" do
    context "when API returns idCaptcha" do
      it "returns the captcha id" do
        stub_http(body: { "idCaptcha" => captcha_id })
        expect(described_class.crear).to eq(captcha_id)
      end
    end

    context "when API returns business error" do
      it "returns nil and logs the error" do
        stub_http(body: { "errorMessage" => "[0301]Organismo no autorizado" })
        expect(Rails.logger).to receive(:error).with(/0301/)
        expect(described_class.crear).to be_nil
      end
    end

    context "when API returns HTTP 401" do
      it "returns nil and logs the error" do
        stub_http(body: {}, code: "401")
        expect(Rails.logger).to receive(:error).with(/401/)
        expect(described_class.crear).to be_nil
      end
    end

    context "when connection times out" do
      it "returns nil and logs timeout" do
        allow(http_double).to receive(:request).and_raise(Net::ReadTimeout)
        expect(Rails.logger).to receive(:error).with(/timeout/)
        expect(described_class.crear).to be_nil
      end
    end

    context "when connection is refused" do
      it "returns nil and logs the error" do
        allow(http_double).to receive(:request).and_raise(Errno::ECONNREFUSED)
        expect(Rails.logger).to receive(:error)
        expect(described_class.crear).to be_nil
      end
    end
  end

  describe ".validar" do
    let(:valor) { "1234" }

    context "when captcha is correct" do
      it "returns true" do
        stub_http(body: { "valido" => true })
        expect(described_class.validar(captcha_id, valor)).to be true
      end
    end

    context "when captcha is incorrect" do
      it "returns false" do
        stub_http(body: { "valido" => false })
        expect(described_class.validar(captcha_id, valor)).to be false
      end
    end

    context "when valido is string 'true'" do
      it "returns true" do
        stub_http(body: { "valido" => "true" })
        expect(described_class.validar(captcha_id, valor)).to be true
      end
    end

    context "when API returns business error 0101 (service down)" do
      it "returns false and logs the error" do
        stub_http(body: { "errorMessage" => "[0101]Imposible ejecutar el servicio" })
        expect(Rails.logger).to receive(:error).with(/0101/)
        expect(described_class.validar(captcha_id, valor)).to be false
      end
    end

    context "when connection times out" do
      it "returns false and logs timeout" do
        allow(http_double).to receive(:request).and_raise(Net::OpenTimeout)
        expect(Rails.logger).to receive(:error).with(/timeout/)
        expect(described_class.validar(captcha_id, valor)).to be false
      end
    end
  end

  describe ".front_js_url" do
    context "in production" do
      it "returns production URL" do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))
        expect(described_class.front_js_url).to include("ptt-captcha-front.gva.es")
        expect(described_class.front_js_url).not_to include("-pre")
      end
    end

    context "outside production" do
      it "returns PRE URL" do
        expect(described_class.front_js_url).to include("ptt-captcha-front-pre.gva.es")
      end
    end
  end

  describe "error logging" do
    it "logs error code 0809 (missing x-api-key header)" do
      stub_http(body: { "errorMessage" => "[0809]Falta la cabecera x-api-key" })
      expect(Rails.logger).to receive(:error).with(/0809/)
      described_class.crear
    end

    it "logs error code 0810 (missing aplicacion header)" do
      stub_http(body: { "errorMessage" => "[0810]Falta la cabecera aplicacion" })
      expect(Rails.logger).to receive(:error).with(/0810/)
      described_class.crear
    end

    it "logs HTTP 422 error" do
      stub_http(body: {}, code: "422")
      expect(Rails.logger).to receive(:error).with(/422/)
      described_class.crear
    end
  end
end
