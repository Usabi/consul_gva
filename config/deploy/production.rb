set :branch, ENV["branch"] || :devel

server deploysecret(:server), user: deploysecret(:user), roles: %w[web app db importer cron background]
# server main_deploy_server, user: deploysecret(:user), roles: %w[web app db importer cron background]
#server deploysecret(:server1), user: deploysecret(:user), roles: %w[web app db importer cron background]
#server deploysecret(:server2), user: deploysecret(:user), roles: %w(web app db importer cron background)
#server deploysecret(:server3), user: deploysecret(:user), roles: %w(web app db importer)
#server deploysecret(:server4), user: deploysecret(:user), roles: %w(web app db importer)
