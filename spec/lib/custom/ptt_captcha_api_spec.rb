require "rails_helper"

describe PttCaptchaApi do
  let(:captcha_id) { "CEJWBDAZ-A0BFGDT8-T8SWQARC" }

  before do
    allow(PttCaptcha.configuration).to receive(:app_id).and_return("TEST-APP")
    allow(PttCaptcha.configuration).to receive(:x_api_key).and_return("test-x-api-key")
    allow(PttCaptcha.configuration).to receive(:aplicacion).and_return("test-aplicacion")
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

  describe ".create_captcha" do
    context "when API returns idCaptcha" do
      it "returns the captcha id" do
        stub_http(body: { "idCaptcha" => captcha_id })
        expect(described_class.create_captcha).to eq(captcha_id)
      end
    end

    context "when API returns business error" do
      it "returns nil and logs the error" do
        stub_http(body: { "errorMessage" => "[0301]Organismo no autorizado" })
        expect(Rails.logger).to receive(:error).with(/0301/)
        expect(described_class.create_captcha).to be_nil
      end
    end

    context "when API returns HTTP 401" do
      it "returns nil and logs the error" do
        stub_http(body: {}, code: "401")
        expect(Rails.logger).to receive(:error).with(/401/)
        expect(described_class.create_captcha).to be_nil
      end
    end

    context "when connection times out" do
      it "returns nil and logs timeout" do
        allow(http_double).to receive(:request).and_raise(Net::ReadTimeout)
        expect(Rails.logger).to receive(:error).with(/timeout/)
        expect(described_class.create_captcha).to be_nil
      end
    end

    context "when connection is refused" do
      it "returns nil and logs the error" do
        allow(http_double).to receive(:request).and_raise(Errno::ECONNREFUSED)
        expect(Rails.logger).to receive(:error)
        expect(described_class.create_captcha).to be_nil
      end
    end
  end

  describe "XML responses from the BUS" do
    def stub_raw_http(body:, code: "500")
      response = instance_double(Net::HTTPResponse, code: code, body: body)
      allow(http_double).to receive(:request).and_return(response)
    end

    it "extracts the PAI error from an XML fault" do
      stub_raw_http(body: <<~XML)
        <?xml version="1.0" encoding="UTF-8"?>
        <err:RestError xmlns:err="http://www.bea.com/wli/sb/errors">
          <err:errorMessage>[0301]Organismo no autorizado</err:errorMessage>
        </err:RestError>
      XML

      expect(described_class.create_captcha).to be_nil
      expect(described_class.last_error).to include("0301")
      expect(described_class.last_error).to include("PAI")
    end

    it "reports an unrecognized XML body instead of failing to parse it" do
      stub_raw_http(body: "<html><body>Service unavailable</body></html>", code: "503")

      expect(described_class.create_captcha).to be_nil
      expect(described_class.last_error).to include("Respuesta XML no reconocida")
    end

    it "asks for JSON responses" do
      stub_http(body: { "idCaptcha" => captcha_id })
      headers = {}
      allow(Net::HTTP::Post).to receive(:new).and_wrap_original do |original, *args|
        original.call(*args).tap { |request| headers[:request] = request }
      end

      described_class.create_captcha

      expect(headers[:request]["Accept"]).to eq("application/json")
    end
  end

  describe "request headers" do
    def sent_request_bytes
      captured = nil
      response = instance_double(Net::HTTPResponse, code: "200", body: { "idCaptcha" => captcha_id }.to_json)
      allow(http_double).to receive(:request) do |request|
        captured = request
        response
      end

      described_class.create_captcha

      io = StringIO.new
      io.define_singleton_method(:continue_timeout) { nil }
      captured.exec(io, "1.1", captured.path)
      io.string
    end

    it "sends x-api-key and aplicacion with the exact lowercase names of the contract" do
      raw = sent_request_bytes

      expect(raw).to include("\r\nx-api-key: test-x-api-key\r\n")
      expect(raw).to include("\r\naplicacion: test-aplicacion\r\n")
      expect(raw).not_to include("X-Api-Key")
      expect(raw).not_to include("Aplicacion:")
    end

    it "keeps the usual capitalization for the other headers" do
      raw = sent_request_bytes

      expect(raw).to include("\r\nContent-Type: application/json\r\n")
      expect(raw).to include("\r\nAccept: application/json\r\n")
    end

    it "strips whitespace around the configured credentials" do
      allow(PttCaptcha.configuration).to receive_messages(x_api_key: "  test-x-api-key\n",
                                                          aplicacion: " test-aplicacion ")

      raw = sent_request_bytes

      expect(raw).to include("\r\nx-api-key: test-x-api-key\r\n")
      expect(raw).to include("\r\naplicacion: test-aplicacion\r\n")
    end
  end

  describe ".last_error" do
    it "is nil after a successful call" do
      stub_http(body: { "idCaptcha" => captcha_id })

      described_class.create_captcha

      expect(described_class.last_error).to be_nil
    end

    it "describes a PAI business error" do
      stub_http(body: { "errorMessage" => "[0301]Organismo no autorizado" })

      described_class.create_captcha

      expect(described_class.last_error).to include("0301")
      expect(described_class.last_error).to include("/crear")
    end

    it "describes an HTTP error" do
      stub_http(body: {}, code: "401")

      described_class.create_captcha

      expect(described_class.last_error).to include("HTTP 401")
    end

    it "describes a timeout" do
      allow(http_double).to receive(:request).and_raise(Net::ReadTimeout)

      described_class.create_captcha

      expect(described_class.last_error).to include("timeout")
    end

    it "describes a refused connection" do
      allow(http_double).to receive(:request).and_raise(Errno::ECONNREFUSED)

      described_class.create_captcha

      expect(described_class.last_error).to include("Errno::ECONNREFUSED")
    end

    it "is cleared by the next successful call" do
      allow(http_double).to receive(:request).and_raise(Errno::ECONNREFUSED)
      described_class.create_captcha
      stub_http(body: { "idCaptcha" => captcha_id })

      described_class.create_captcha

      expect(described_class.last_error).to be_nil
    end

    it "never includes the configured credentials" do
      allow(http_double).to receive(:request).and_raise(Errno::ECONNREFUSED)

      described_class.create_captcha

      expect(described_class.last_error).not_to include("test-x-api-key")
      expect(described_class.last_error).not_to include("TEST-APP")
    end
  end

  describe ".validate_captcha" do
    let(:valor) { "1234" }

    context "when captcha is correct" do
      it "returns true" do
        stub_http(body: { "valido" => true })
        expect(described_class.validate_captcha(captcha_id, valor)).to be true
      end
    end

    context "when captcha is incorrect" do
      it "returns false" do
        stub_http(body: { "valido" => false })
        expect(described_class.validate_captcha(captcha_id, valor)).to be false
      end
    end

    context "when valido is string 'true'" do
      it "returns true" do
        stub_http(body: { "valido" => "true" })
        expect(described_class.validate_captcha(captcha_id, valor)).to be true
      end
    end

    context "when API returns business error 0101 (service down)" do
      it "returns false and logs the error" do
        stub_http(body: { "errorMessage" => "[0101]Imposible ejecutar el servicio" })
        expect(Rails.logger).to receive(:error).with(/0101/)
        expect(described_class.validate_captcha(captcha_id, valor)).to be false
      end
    end

    context "when API returns HTTP 422" do
      it "logs the response body returned by the BUS to tell expired from reused captchas" do
        stub_http(body: { "detalle" => "captcha caducado" }, code: "422")

        expect(Rails.logger).to receive(:error).with(/422.*captcha caducado/)
        expect(described_class.validate_captcha(captcha_id, valor)).to be false
      end

      it "keeps the response body in last_error without leaking the typed value" do
        stub_http(body: { "detalle" => "captcha caducado" }, code: "422")

        described_class.validate_captcha(captcha_id, "secreto-9876")

        expect(described_class.last_error).to include("captcha caducado")
        expect(described_class.last_error).not_to include("secreto-9876")
      end
    end

    context "when connection times out" do
      it "returns false and logs timeout" do
        allow(http_double).to receive(:request).and_raise(Net::OpenTimeout)
        expect(Rails.logger).to receive(:error).with(/timeout/)
        expect(described_class.validate_captcha(captcha_id, valor)).to be false
      end
    end
  end

  describe ".base_url" do
    after { PttCaptcha.configuration.base_url = nil }

    context "when a base_url is configured" do
      it "returns it without trailing slash" do
        PttCaptcha.configuration.base_url = "https://innovacion-pre.gva.es/custom/CAPTCHA_REST_v1_00/"

        expect(described_class.base_url).to eq("https://innovacion-pre.gva.es/custom/CAPTCHA_REST_v1_00")
      end

      it "is used by create_captcha" do
        PttCaptcha.configuration.base_url = "https://custom.example/CAPTCHA_REST_v1_00"
        stub_http(body: { "idCaptcha" => captcha_id })

        described_class.create_captcha

        expect(Net::HTTP).to have_received(:new).with("custom.example", 443)
      end
    end

    context "when base_url is blank" do
      before { PttCaptcha.configuration.base_url = "" }

      it "falls back to the PRE URL outside production" do
        expect(described_class.base_url).to eq(described_class::BASE_PRE)
      end

      it "falls back to the production URL in production" do
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))

        expect(described_class.base_url).to eq(described_class::BASE_PROD)
      end
    end
  end

  describe ".front_js_url" do
    context "when a front_js_url is configured" do
      after { PttCaptcha.configuration.front_js_url = nil }

      it "returns it even in production" do
        PttCaptcha.configuration.front_js_url = "https://ptt-captcha-front-pre.gva.es/ptt-captcha-front/js/ptt-captcha.js"
        allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new("production"))

        expect(described_class.front_js_url).to include("ptt-captcha-front-pre.gva.es")
      end
    end

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
      described_class.create_captcha
    end

    it "logs error code 0810 (missing aplicacion header)" do
      stub_http(body: { "errorMessage" => "[0810]Falta la cabecera aplicacion" })
      expect(Rails.logger).to receive(:error).with(/0810/)
      described_class.create_captcha
    end

    it "logs HTTP 422 error" do
      stub_http(body: {}, code: "422")
      expect(Rails.logger).to receive(:error).with(/422/)
      described_class.create_captcha
    end

    it "uses the translated description from locales for a known business error code" do
      stub_http(body: { "errorMessage" => "[0301]Organismo no autorizado" })
      expect(Rails.logger).to receive(:error)
        .with("PttCaptchaApi [/crear] error PAI 0301: Organismo no autorizado — revisar credenciales PAI")
      described_class.create_captcha
    end

    it "falls back to the API's own message for an unknown business error code" do
      stub_http(body: { "errorMessage" => "[9999]Mensaje no mapeado" })
      expect(Rails.logger).to receive(:error).with(/\[9999\]Mensaje no mapeado/)
      described_class.create_captcha
    end

    it "uses the translated description from locales for a known HTTP error code" do
      stub_http(body: {}, code: "404")
      expect(Rails.logger).to receive(:error)
        .with("PttCaptchaApi [/crear] HTTP 404: Recurso no encontrado")
      described_class.create_captcha
    end

    it "falls back to 'desconocido' for an unmapped HTTP error code" do
      stub_http(body: {}, code: "503")
      expect(Rails.logger).to receive(:error).with("PttCaptchaApi [/crear] HTTP 503: desconocido")
      described_class.create_captcha
    end
  end
end
