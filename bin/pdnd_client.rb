# frozen_string_literal: true

#!/usr/bin/env ruby # rubocop:disable Layout/LeadingCommentSpace

require 'optparse'
require_relative '../lib/pdnd_ruby_client'

options = {
  env: 'produzione',
  config: 'configs/sample.json',
  debug: false,
  verify_ssl: true,
  api_url: '',
  status_url: '',
  filters: [],
  token_file: 'tmp/pdnd_token.json',
  save: false
}

OptionParser.new do |opts|
  opts.banner = 'Usage: pdnd_client.rb [options]'
  opts.on('--config PATH', 'Path al file JSON') { |v| options[:config] = v }
  opts.on('--env ENV', 'Ambiente (collaudo/produzione)') { |v| options[:env] = v }
  opts.on('--status-url URL', 'URL per verifica token') { |v| options[:status_url] = v }
  opts.on('--api-url URL', 'URL API da chiamare') { |v| options[:api_url] = v }
  opts.on('--api-url-filters STR', 'Filtri API (es. id=123)') { |v| options[:filters] = v }
  opts.on('--token-file PATH', 'File token') { |v| options[:token_file] = v }
  opts.on('--debug', 'Modalità debug') { options[:debug] = true }
  opts.on('--no-verify-ssl', 'Disabilita verifica SSL') { options[:verify_ssl] = false }
  opts.on('--save', 'Salva token') { options[:save] = true }
end.parse!

begin
  config = PDND::ConfigLoader.load(options[:config], options[:env])
  token_mgr = PDND::TokenManager.new(options[:token_file])
  token, exp = token_mgr.load

  if token.nil? || !token_mgr.valid?
    jwt = PDND::JWTGenerator.new(config, options[:env])
    jwt.debug = options[:debug]
    token, exp = jwt.generate_token
    token_mgr.save(token, exp) if options[:save]
  end

  client = PDND::Client.new(config)
  client.debug = options[:debug]
  client.verify_ssl = options[:verify_ssl]
  client.token = token
  client.token_exp = exp

  if options[:status_url]
    client.status_url = options[:status_url]
    code, response = client.check_status
    puts "🔍 Verifica token – codice: #{code}" if options[:debug]
    puts JSON.pretty_generate(response)
  end

  if options[:api_url]
    client.api_url = options[:api_url]
    client.filters = options[:filters]
    code, response = client.request_api
    puts "✅ Codice: #{code}" if options[:debug]
    puts JSON.pretty_generate(response)
  end
rescue PDND::APIError => e
  puts "⚠️ Errore: #{e.message}"
  puts e.backtrace.join("\n") if options[:debug]
  exit(1)
end
