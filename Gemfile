# frozen_string_literal: true

# Gemfile (radice del progetto della gemma)
source 'https://rubygems.org'

gemspec

# Gemme runtime
gem 'dotenv', '~> 3.2'
gem 'faraday', '~> 2.14'
gem 'json', '~> 2.21'
gem 'jwt', '~> 3.2'
gem 'uri', '~> 1.1', '>= 1.1'

# Gemme di sviluppo e test
group :development, :test do
  gem 'rspec', '~> 3.13'
  gem 'rubocop', '~> 1.88'
end

group :development do
  gem 'github_changelog_generator', '~> 1.18'
  gem 'irb', '~> 1.18'
  gem 'rdoc', '8.0'
end

group :test do
  gem 'simplecov', '~> 1.0'
end
