# PRODUCTION-specific deployment configuration
# please put general deployment config in config/deploy.rb

#use trunk to deploy to production
  set :branch, "master"
  set :rails_env, 'production'

#production
  set :domain, 'server'
  role :app, domain
  role :web, domain
  role :db, domain, :primary => true

