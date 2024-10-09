namespace :usabi do
  desc "Update database and settings"
  task execute_update_tasks: [
                              "recaptcha:verify_recaptcha",
                              "unaccent:verify_unaccent",
                              "consul:execute_release_tasks",
                              "milestone:create_status"
                             ]
end
