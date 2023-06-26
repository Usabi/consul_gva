namespace :usabi do
  desc "Update database and settings"
  task execute_update_tasks: [
                              "consul:execute_release_1.4.0_tasks"
                             ]
end
