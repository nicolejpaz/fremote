source 'https://rubygems.org'

gem 'rails', '4.0.2'
gem 'mongoid', git: 'https://github.com/mongoid/mongoid.git'
gem 'bson_ext'
gem 'puma'
gem 'bootstrap-sass'
gem 'sass-rails', '~> 4.0.0'
gem 'less-rails'
gem 'uglifier', '>= 1.3.0'
gem 'haml'
gem 'rails_layout', git: 'https://github.com/RailsApps/rails_layout.git'
gem 'therubyracer', platforms: :ruby
gem 'jquery-rails'
gem 'jbuilder', '~> 1.2'
gem 'devise'
gem 'guard-rails'
gem 'viddl-rb', git: 'https://github.com/Ravenstine/viddl-rb.git'
gem 'pluggable_js', '~> 2.0.0'
gem 'rack-zippy'
gem 'metamagic'
gem 'google-analytics-rails'
gem 'sitemap'

group :doc do
  gem 'sdoc', require: false
end

group :test do
  gem 'database_cleaner'
  gem 'capybara'
  gem 'vcr'
  gem 'webmock'
  gem 'simplecov', :require => false
end

group :test, :development do
  gem 'factory_girl_rails'
  gem 'email_spec'
  gem 'debugger'
  gem 'rspec-rails'
  gem 'mongoid-rspec'
  gem 'faker'
end

group :production do
  gem 'rails_12factor'
end