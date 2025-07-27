# frozen_string_literal: true

require_relative 'lib/pdnd_ruby_client/version'

Gem::Specification.new do |spec|
  spec.name          = 'pdnd_ruby_client'
  spec.version       = PDND::ClientVersion::VERSION
  spec.authors       = ['Francesco Loreti']
  spec.email         = ['francesco.loreti@isprambiente.it']
  spec.summary       = 'Client Ruby per la PDND.'
  spec.description   = 'Client Ruby per interazione con le API della Piattaforma Digitale Nazionale Dati (PDND).'
  spec.homepage      = 'https://github.com/isprambiente/pdnd-ruby-client'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.2.0'

  spec.metadata = {
    'homepage_uri' => spec.homepage,
    'changelog_uri' => "https://github.com/isprambiente/pdnd-ruby-client/changelog.md",
    'rubygems_mfa_required' => 'true'
  }

  gemspec = File.basename(__FILE__)
  tracked_files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      f == gemspec ||
        f == 'CODE_OF_CONDUCT.md' ||
        f == 'LICENSE.txt' ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end

  tracked_files << 'LICENSE' unless tracked_files.include?('LICENSE')

  spec.files = tracked_files
  spec.bindir = 'bin'
  spec.executables = tracked_files.grep(%r{\Abin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'dotenv', '~> 2.8'
  spec.add_dependency 'faraday', '~> 2.13'
  spec.add_dependency 'json', '~> 2.0'
  spec.add_dependency 'jwt', '~> 3.1'
  spec.add_dependency 'net-http', '~> 0.3', '>= 0.3.2'
end
