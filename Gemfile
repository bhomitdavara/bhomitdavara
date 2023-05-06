source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.4'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.0.3'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets', '~> 3.7.2'

# Use sqlite3 as the database for Active Record
gem 'pg', '~> 1.4.3'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma-daemon', require: false
gem 'puma', '~> 5.1'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'
gem "mini_magick"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

# Use Redis adapter to run Action Cable in production
gem 'redis', '~> 4.0'

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

gem 'activeadmin'
gem 'activeadmin-chat'
gem 'activeadmin_quill_editor'
gem 'activeadmin-searchable_select'
gem 'active_storage_validations'
gem 'arctic_admin'
gem 'aws-sdk-s3', require: false
gem 'bullet'
gem 'devise'
gem 'dotenv-rails'
gem 'fcm'
gem 'gon'
gem 'image_processing', '~> 1.2'
gem 'jsonapi-serializer'
gem 'jwt', '~> 1.0'
gem 'pagy', '~> 5.10'
# gem 'ruby-vips'
gem 'twilio-ruby', '~> 4.1.0'
gem 'webpacker', '~> 5.0'
# Use Sass to process CSS
gem 'sass-rails', '~> 5.1.0 '

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri mingw x64_mingw]
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end
group :development do
  #deployment
  gem 'capistrano'
  gem 'capistrano-rails'
  gem 'capistrano-bundler'
  gem 'capistrano-rbenv'
  gem "capistrano3-puma", require: false, github: "seuros/capistrano-puma"
  gem 'net-ssh', '>= 6.0.2'
  gem 'ed25519', '>= 1.2', '< 2.0'
  gem 'bcrypt_pbkdf', '>= 1.0', '< 2.0'
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end

gem "foreman"
gem 'noticed', '~> 1.5'

gem "streamio-ffmpeg", "~> 3.0"