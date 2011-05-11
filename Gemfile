source 'http://rubygems.org'

gem 'rails', '~> 3.0.7'

gem 'mysql2', '~> 0.2.7'

gem 'sass'
gem 'haml'

gem 'warden'
gem 'devise'#, :git => "https://github.com/plataformatec/devise.git", :ref => "a23a52b2f7224d16f38d"
gem 'bcrypt-ruby', :require => 'bcrypt'

gem 'simple_form'

gem 'will_paginate', '>= 3.0.beta'
gem 'jammit'#, :git => "https://github.com/documentcloud/jammit.git"

gem 'rdf', :git => "https://github.com/bendiken/rdf.git"
gem 'sparql-client', :git => "https://github.com/bendiken/sparql-client.git"

gem 'uuidtools'
gem 'redis'
gem "resque", :require => "resque/server"
gem "yajl-ruby", :require => "yajl"

group :development, :test, :cucumber do
  gem "rspec-rails", ">= 2.5.0"
#  gem "net-http-spy"
end

group :test, :cucumber do
  # bundler requires these gems while running tests
  gem "capybara"#, :git => "https://github.com/jnicklas/capybara.git"
  gem 'database_cleaner'#, :git => "http://github.com/bmabey/database_cleaner.git"
  gem 'cucumber-rails'
  gem 'cucumber'
  gem 'spork'
  gem 'launchy'    # So you can do Then show me the page
  gem 'webrat'
  gem "rspec", ">= 2.5.0"
  gem 'factory_girl_rails'
  gem 'fakeweb'
  gem 'rest-client'
  gem 'simplecov'
end
