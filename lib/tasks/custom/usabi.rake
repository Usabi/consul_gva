namespace :usabi do
  desc "Update database and settings"
  task execute_update_tasks: [
                              "settings:add_new_settings",
                              "sitemap:refresh:no_ping"
                             ]
end
