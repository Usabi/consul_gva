require_dependency Rails.root.join("app", "models", "signature").to_s

class Signature < ApplicationRecord

  attr_accessor :gender, :name, :first_surname, :last_surname, :foreign_residence

  def in_census?
    other_data = { date_of_birth: date_of_birth, postal_code: postal_code, name: name, first_surname: first_surname, last_surname: last_surname }
    document_types.find do |document_type|
      response = CensusCaller.new.call(document_type, document_number, other_data)
      if response.valid?
        @census_api_response = response
        true
      else
        false
      end
    end

    @census_api_response.present?
  end
end
