namespace :usabi do
  desc "Update database and settings"
  task execute_update_tasks: [
                              "db:migrate",
                              "settings:add_new_settings",
                              "consul:execute_release_tasks",
                              "sitemap:refresh:no_ping",
                              "consul:execute_release_1.3.0_tasks"
                            ]
end
