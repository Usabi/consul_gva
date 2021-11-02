module Consul
  class Application < Rails::Application
    config.autoload_paths << "#{Rails.root}/app/models/custom/concerns"
    config.autoload_paths << "#{Rails.root}/app/controllers/custom/concerns"
    config.autoload_paths << "#{Rails.root}/app/mailers/custom"

    config.autoload_paths.unshift(Rails.root.join("lib/custom"))
    config.i18n.default_locale = :val
    available_locales = [
      "val",
      "es"]
    config.i18n.available_locales = available_locales
  end
end
