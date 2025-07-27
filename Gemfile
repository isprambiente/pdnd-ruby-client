# frozen_string_literal: true

# Gemfile (radice del progetto della gemma)
source 'https://rubygems.org'

gemspec

# Gemme runtime
gem 'dotenv', '~> 2.8'
gem 'faraday', '~> 2.13'
gem 'json', '>= 2.0'
gem 'jwt', '~> 3.1'

# Gemme di sviluppo e test
group :development, :test do
  gem 'rspec', '~> 3.12'
  gem 'rubocop', '~> 1.58'
end

group :development do
  gem 'irb'
  gem 'rdoc'
  gem 'github_changelog_generator'
end

group :test do
  gem 'simplecov', '~> 0.22'
end
