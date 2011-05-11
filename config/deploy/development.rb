# DEVELOPMENT-specific deployment configuration
# please put general deployment config in config/deploy.rb

#use branch/dev to deploy to dev
  set :branch, "dev"
  set :rails_env, 'development'

#development
  set :domain, 'server'
  role :app, domain
  role :web, domain
  role :db, domain, :primary => true


