require "rails_helper"
require "timecop"

describe CensusApi do
  let(:api) { CensusApi.new }

  let(:other_data) do
    {
      name: "Francisca",
      first_surname: "Nomdedéu",
      last_surname: "Camps",
      date_of_birth: "19771019",
      postal_code: "46100"
    }
  end

  let(:valid_body) do
    {
      datos_habitante: {
        "resultado" => true,
        "error" => false,
        "cod_estado" => "00",
        "literal_error" => "INFORMACION CORRECTA",
        "nacionalidad" => "ESPAÑA",
        "nombre" => "Francisca",
        "apellido1" => "Nomdedéu",
        "apellido2" => "Camps",
        "sexo" => "M",
        "fecha_nacimiento" => "19771019"
      },
      datos_vivienda: {
        "resultado" => true,
        "error" => false,
        "estado" => "0003",
        "literal" => "Verificación positiva. Ámbito Territorial de Residencia Correcto."
      },
      datos_originales: other_data
    }
  end

  let(:invalid_age_body) do
    valid_body.merge({ datos_habitante: { "resultado" => false, "error" => "error servicio edad" }})
  end

  let(:invalid_residence_body) do
    valid_body.merge({ datos_vivienda: { "resultado" => false, "error" => "error servicio residencia" }})
  end

  let(:unavailable_age_body) do
    valid_body.merge({ datos_habitante: { "resultado" => false, "error" => "Servicio no disponible..." }})
  end

  let(:unavailable_residence_body) do
    valid_body.merge({ datos_vivienda: { "resultado" => false, "error" => "Servicio no disponible..." }})
  end

  describe "#call" do
    it "returns valid response" do
      allow(api).to receive(:get_response_body).with("1", "0123456", other_data).and_return(valid_body)
      response = api.call("1", "0123456", other_data)

      expect(response).to be_valid
      expect(response.date_of_birth).to eq(Date.new(1977, 10, 19))
      expect(response.postal_code).to eq("46100")
      expect(response.district_code).to eq("46")
    end

    it "returns failed age response" do
      allow(api).to receive(:get_response_body).with("1", "123456", other_data).and_return(invalid_age_body)
      response = api.call("1", "123456", other_data)

      expect(response).not_to be_valid
      expect(response.error).to eq("error servicio edad")
    end

    it "returns failed residence response" do
      allow(api).to receive(:get_response_body).with("1", "123456",
other_data).and_return(invalid_residence_body)
      response = api.call("1", "123456", other_data)

      expect(response).not_to be_valid
      expect(response.error).to eq("error servicio residencia")
    end

    it "returns unavailable age service" do
      allow(api).to receive(:get_response_body).with("1", "0123456",
other_data).and_return(unavailable_age_body)
      response = api.call("1", "0123456", other_data)

      expect(response).not_to be_valid
      expect(response.error).to eq("Servicio no disponible...")
    end

    it "returns unavailable residence service" do
      allow(api).to receive(:get_response_body).with("1", "0123456",
other_data).and_return(unavailable_residence_body)
      response = api.call("1", "0123456", other_data)

      expect(response).not_to be_valid
      expect(response.error).to eq("Servicio no disponible...")
    end
  end

  context "ConnectionCensus" do
    let(:conn) { CensusApi::ConnectionCensus.new }
    let(:other_data) do
 { name: "Francisca", first_surname: "Nomdedéu", last_surname: "Camps", date_of_birth: "19771019",
postal_code: "46001" } end

    describe "#call" do
      before do
        allow(Rails.application.secrets).to receive(:census_api_age_validator).and_return("validadorEdad")
        allow(Rails.application.secrets).to receive(:census_api_residence_validator).and_return("validadorResidencia")
      end

      context "NIF valid" do
        it "calls php validators with right parameters" do
          Timecop.freeze do
            valid_age_call = %(php -f validadorEdad -- -i #{Time.now.to_i.to_s[-7..-1]} -n 12345678Z -o "Francisca" -a "Nomdedéu" -p "Camps" )
            expect_any_instance_of(CensusApi::ConnectionCensus).to receive(:`).with(valid_age_call).and_return(valid_body[:datos_habitante].to_json)

            valid_residence_call = %(php -f validadorResidencia -- -i #{Time.now.to_i.to_s[-7..-1]} -n 12345678Z -p 46 --esp s)
            expect_any_instance_of(CensusApi::ConnectionCensus).to receive(:`).with(valid_residence_call).and_return(valid_body[:datos_vivienda].to_json)

            expected = { datos_habitante: valid_body[:datos_habitante],
datos_vivienda: valid_body[:datos_vivienda], datos_originales: other_data }
            expect(conn.call("1", "12345678Z", other_data)).to eq(expected)
          end
        end
      end

      context "NIE valid" do
        it "calls php validators with right parameters" do
          Timecop.freeze do
            valid_age_call = %(php -f validadorEdad -- -i #{Time.now.to_i.to_s[-7..-1]} -n 12345678Z -o "Francisca" -a "Nomdedéu" -p "Camps" --esp n)
            expect_any_instance_of(CensusApi::ConnectionCensus).to receive(:`).with(valid_age_call).and_return(valid_body[:datos_habitante].to_json)

            valid_residence_call = %(php -f validadorResidencia -- -i #{Time.now.to_i.to_s[-7..-1]} -n 12345678Z -p 46 --esp n)
            expect_any_instance_of(CensusApi::ConnectionCensus).to receive(:`).with(valid_residence_call).and_return(valid_body[:datos_vivienda].to_json)

            expected = { datos_habitante: valid_body[:datos_habitante],
datos_vivienda: valid_body[:datos_vivienda], datos_originales: other_data }
            expect(conn.call("4", "12345678Z", other_data)).to eq(expected)
          end
        end
      end
    end
  end
end
