source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.6'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.4'

# Use Puma as the app server
gem 'puma', '~> 4.3'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

gem 'bootstrap', '~> 4.3.1'
gem 'jquery-rails'

gem 'bootstrap-datepicker-rails'
gem 'rails-assets-jquery-validate', source: 'https://rails-assets.org'

gem 'font-awesome-sass', '~> 5.3.1'

gem 'dotenv-rails', groups: %i[development test]

# Resize image
gem 'lizard', '~> 1.0'

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'

# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5.2.0'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'

# Use Queue backend
gem 'resque'
gem 'rufus-scheduler'

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'

gem 'keytechkit', '~> 1.1' # , :path => '/Users/thorstenclaus/Documents/develop/web-projekte/keytechKit.gem'


# User Auth
gem 'devise'
gem 'devise-i18n'

# Send emails
gem 'mailgun-ruby'

# Non Blocking Notifications
gem 'toastr-rails'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %>
  # anywhere in the code.
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'sqlite3', '~> 1.3.6'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the
  # background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  gem 'webdrivers', '~> 4.0'
end

group :production do
  gem 'pg'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
