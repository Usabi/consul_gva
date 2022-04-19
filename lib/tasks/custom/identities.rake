namespace :identities do
  desc "Resets identities"
  task reset_identities: :environment do
    Identity.find_each do |resource|
      user = resource.user
      if user
        user.document_type = nil
        user.document_number = nil
        user.save!
      end
      resource.delete
    end
  end
end
