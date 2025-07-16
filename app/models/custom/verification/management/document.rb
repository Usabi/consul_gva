load Rails.root.join("app", "models", "verification", "management", "document.rb")

class Verification::Management::Document

  def in_census?
    other_data = { date_of_birth: date_of_birth, postal_code: postal_code }
    response = CensusCaller.new.call(document_type, document_number, other_data)
    response.valid? && valid_age?(response)
  end
end
