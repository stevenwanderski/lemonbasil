source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.6'

gem 'rails', '~> 6.0.3', '>= 6.0.3.2'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 4.1'
gem 'sass-rails', '>= 6'
gem 'sassc', '~> 2.1.0'
gem 'active_link_to'
gem 'awesome_print'
gem 'devise'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'kramdown'
gem 'recaptcha'
gem 'webpacker', '~> 5.x'
gem 'active_model_serializers', '~> 0.10.0'
gem 'premailer-rails'
gem 'deep_cloneable'

group :development do
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'guard-livereload', '~> 2.5', require: false
  gem 'annotate'
end

group :development, :test do
  gem 'rspec-rails', '~> 4.0.1'
  gem 'dotenv-rails'
end

group :test do
  gem 'factory_bot_rails'
  gem 'capybara'
  gem 'database_cleaner-active_record'
  gem 'webdrivers', '~> 3.7', '>= 3.7.2'
  gem 'capybara-selenium', '~> 0.0.6'
end
