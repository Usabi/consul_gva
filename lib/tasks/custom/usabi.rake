namespace :usabi do
  desc "Update database and settings"
  task execute_update_tasks: [
                              "recaptcha:verify_recaptcha",
                              "web_sections:update"
                             ]
end
