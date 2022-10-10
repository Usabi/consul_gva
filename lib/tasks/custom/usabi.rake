namespace :usabi do
  desc "Update database and settings"
  task execute_update_tasks: [
                              "gvlogin_user_desa:reset_organizations"
                             ]
end
