set :branch, "issue/7683-update-2.2.2-custom_changes"

set :bundle_path, -> { release_path.join('vendor/bundle') }
# set :linked_dirs, %w[log tmp public/system]
set :gva_svn_path, -> { "#{ENV['PWD']}_svn" }

# Defaults to nil (no asset cleanup is performed)
# If you use Rails 4+ and you'd like to clean up old assets after each deploy,
# set this to the number of versions to keep
set :keep_assets, 1

server deploysecret(:server), user: deploysecret(:user), roles: %w[web app db importer cron background]
#server deploysecret(:server2), user: deploysecret(:user), roles: %w(web app db importer cron background)
#server deploysecret(:server3), user: deploysecret(:user), roles: %w(web app db importer)
#server deploysecret(:server4), user: deploysecret(:user), roles: %w(web app db importer)

namespace :deploy do
  # Uncomment this to automatically do the rsync of the office server compiled code to local folder
  # (defined with gva_svn_path setting. By default ../<project_folder>_svn)
  # Or launch the task with "cap production_gva deploy:gva_subversion_copy"
  after :finished, "deploy:gva_subversion_copy"
end
