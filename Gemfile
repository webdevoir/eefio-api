source 'https://rubygems.org'

# Required Ruby version
ruby '2.5.1'

gem 'rails', '~> 5.2.1'

# Database
gem 'pg', '>= 0.18', '< 2.0'

# Webserv
gem 'puma'

# API JSON views
gem 'jbuilder', '~> 2.5'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

# For open CORS (Cross-Origin Resource Sharing), making cross-origin AJAX possible
gem 'rack-cors'

# For Ethereum network API
gem 'web3-eth'

# For background workers
gem 'sidekiq'

# For code style guide and linting
gem 'rubocop', require: false
gem 'rubocop-rspec'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]

  # For setting and loading ENVironment variables in non-production
  gem 'dotenv-rails'

  # For Testing
  gem 'rspec-rails'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# TODO: fix upstream
# group :production do
#   # For GZIPping responses
#   gem 'heroku-deflater'
# end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
