# VmcrcPersona reads owcrc.vmcrc_siac_personas, a view in an external database
# managed by the client that only exists in production. In tests there is no
# such view and no migration creates it, so we create a stand-in table with the
# columns we use. It's created before the suite instead of in db/schema.rb so
# it doesn't end up in the application schema.
RSpec.configure do |config|
  config.before(:suite) do
    ActiveRecord::Base.connection.create_table(:vmcrc_siac_personas, if_not_exists: true) do |t|
      %i[codper codmap nomb ape1 ape2 dni dcorreoint].each { |column| t.string column }
    end
  end
end
