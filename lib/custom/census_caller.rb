load Rails.root.join("lib", "census_caller.rb")

class CensusCaller
  def call(document_type, document_number, other_data = {})
    if Setting["feature.remote_census"].present?
      response = RemoteCensusApi.new.call(document_type, document_number, other_data[:date_of_birth], other_data[:postal_code])
    else
      response = CensusApi.new.call(document_type, document_number, other_data)
    end
    local_response = LocalCensus.new.call(document_type, document_number) unless response.valid?

    # If normal responses neither local response are valid, we return normal responses just in case we want to check the error result
    response.valid? || !local_response.valid? ? response : local_response
  end
end
