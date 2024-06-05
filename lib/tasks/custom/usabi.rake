namespace :usabi do
  desc "Update database and settings"
  task execute_update_tasks: [
                              "recaptcha:verify_recaptcha",
                              "consul:execute_release_tasks"
                             ]
end
