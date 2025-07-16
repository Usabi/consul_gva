class VmcrcPersona < ApplicationRecord
  self.table_name = (Rails.env.test? || Rails.env.development?) ? "vmcrc_siac_personas" : "owcrc.vmcrc_siac_personas"
end
