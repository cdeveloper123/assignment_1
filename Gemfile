source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.3'

gem 'rails', '~> 8.0.0'
gem 'sqlite3', '~> 2.1'
gem 'puma', '~> 6.0'
gem 'sass-rails', '>= 6'
gem 'webpacker', '~> 5.0'
gem 'turbo-rails'
gem 'stimulus-rails'
gem 'jbuilder', '~> 2.7'
gem 'bootsnap', '>= 1.4.4', require: false
gem 'image_processing', '~> 1.2'

# Authentication and Authorization
gem 'devise'
gem 'cancancan'

# Admin interface
gem 'activeadmin'

# UI and Styling
gem 'bootstrap', '~> 5.2'
gem 'jquery-rails'

# Charts and Visualizations
gem 'chartkick'
gem 'groupdate'

# Background Jobs
gem 'sidekiq'

# Excel/CSV exports
gem 'caxlsx'
gem 'caxlsx_rails'

# Time handling
gem 'chronic'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
end

group :development do
  gem 'web-console', '>= 4.1.0'
  gem 'listen', '~> 3.3'
  gem 'spring'
end 