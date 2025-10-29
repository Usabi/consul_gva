load Rails.root.join("app", "models", "officing", "residence.rb")

class Officing::Residence
  private

    def retrieve_census_data
      @census_api_response = CensusCaller.new.call(document_type,
                                                   document_number,
                                                   { date_of_birth: date_of_birth,
                                                     postal_code: postal_code })
    end
end
