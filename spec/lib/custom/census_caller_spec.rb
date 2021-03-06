require "rails_helper"

describe CensusCaller do
  let(:api) { CensusCaller.new }

  describe "#call" do
    let(:valid_body) do
      {
        datos_habitante: {
          "resultado" => true,
          "error" => false,
          "nacinalidad" => "España",
          "nombre" => "Francisca",
          "apellido1" => "Nomdedéu",
          "apellido2" => "Camps",
          "sexo" => "M",
          "fecha_nacimiento" => "19-10-1977"
        },
        datos_vivienda: {
          "resultado" => true,
          "error" => false,
          "codigo_provincia" => 46,
          "descripcion_provincia" => "Valencia",
          "codigo_municipio" => "Alzira",
          "direccion" => "C/ Piletes 9, 3º 11",
          "codigo_postal" => 46600
        }
      }
    end
    let(:invalid_body) { valid_body.merge({ datos_habitante: { resultado: false, error: 'some error' } }) }

    it "returns local census response when available and census api response is invalid" do
      census_api_response = CensusApi::Response.new(invalid_body)
      allow_any_instance_of(CensusApi).to receive(:call).and_return(census_api_response)
      local_census_response = LocalCensus::Response.new(create(:local_census_record))
      allow_any_instance_of(LocalCensus).to receive(:call).and_return(local_census_response)

      response = api.call(1, "12345678A")

      expect(response).to eq(local_census_response)
    end

    describe "CensusApi" do
      it "returns census api response when it's available and census api response is valid" do
        census_api_response = CensusApi::Response.new(valid_body)
        allow_any_instance_of(CensusApi).to receive(:call).and_return(census_api_response)

        response = api.call(1, "12345678A")

        expect(response).to eq(census_api_response)
      end

      it "returns census api response when it's available and invalid but local census api is invalid too" do
        census_api_response = CensusApi::Response.new(invalid_body)
        allow_any_instance_of(CensusApi).to receive(:call).and_return(census_api_response)
        expect(LocalCensusRecord).to receive(:find_by).with(document_type: 1, document_number: "12345678").and_return(User.none)
        expect(LocalCensusRecord).to receive(:find_by).with(document_type: 1, document_number: "12345678a").and_return(User.none)
        expect(LocalCensusRecord).to receive(:find_by).with(document_type: 1, document_number: "12345678A").and_return(User.none)

        response = api.call(1, "12345678A")

        expect(response).to eq(census_api_response)
      end
    end

    describe "RemoteCensusApi" do
      let(:valid_body) do
        { get_habita_datos_response: {
          get_habita_datos_return: { datos_habitante: { item: { fecha_nacimiento_string: "1-1-1980" }}}
        }}
      end
      let(:invalid_body) do
        { get_habita_datos_response: { get_habita_datos_return: { datos_habitante: {}}}}
      end

      before do
        Setting["feature.remote_census"] = true
        access_user_data = "datos_habitante"
        Setting["remote_census.response.valid"] = access_user_data
      end

      it "returns remote census api response when it's available and response is valid" do
        remote_census_api_response = RemoteCensusApi::Response.new(valid_body)
        allow_any_instance_of(RemoteCensusApi).to receive(:call).and_return(remote_census_api_response)

        response = api.call(1, "12345678A", date_of_birth: Date.parse("19/10/1977"), postal_code: "46600")

        expect(response).to eq(remote_census_api_response)
      end

      it "returns remote census api response when it's available and valid without send
          date_of_birth and postal_code" do
        remote_census_api_response = RemoteCensusApi::Response.new(valid_body)
        allow_any_instance_of(RemoteCensusApi).to receive(:call).and_return(remote_census_api_response)

        response = api.call(1, "12345678A")

        expect(response).to eq(remote_census_api_response)
      end

      it "returns local census record when remote census api it's available but invalid" do
        remote_census_api_response = RemoteCensusApi::Response.new(invalid_body)
        allow_any_instance_of(RemoteCensusApi).to receive(:call).and_return(remote_census_api_response)
        local_census_response = LocalCensus::Response.new(create(:local_census_record))
        allow_any_instance_of(LocalCensus).to receive(:call).and_return(local_census_response)

        response = api.call(1, "12345678A")

        expect(response).to eq(local_census_response)
      end

      it "returns remote census api response when it's available and invalid but local census api is invalid too" do
        remote_census_api_response = RemoteCensusApi::Response.new(invalid_body)
        allow_any_instance_of(RemoteCensusApi).to receive(:call).and_return(remote_census_api_response)
        expect(LocalCensusRecord).to receive(:find_by).with(document_type: 1, document_number: "12345678").and_return(User.none)
        expect(LocalCensusRecord).to receive(:find_by).with(document_type: 1, document_number: "12345678a").and_return(User.none)
        expect(LocalCensusRecord).to receive(:find_by).with(document_type: 1, document_number: "12345678A").and_return(User.none)

        response = api.call(1, "12345678A")

        expect(response).to eq(remote_census_api_response)
      end
    end
  end
end
