# frozen_string_literal: true

# La classe PDND::Client è responsabile dell'invio di richieste HTTP all'API PDND.
# Gestisce autenticazione via token JWT, invio di richieste GET, parsing dei filtri,
# gestione dello stato, opzioni di debug e verifica del certificato SSL.

require 'net/http'
require 'json'
require 'faraday'

module PDND
  # @!group PDND Client
  # Questa classe gestisce le operazioni di comunicazione con il back-end PDND.
  # @example
  #   client = PDND::Client.new(config)
  #   client.request_api
  #
  # @attr [String] token Il token di autenticazione JWT
  # @attr [Boolean] debug Flag per attivare il logging in console
  class Client
    attr_accessor :token, :token_exp, :debug, :verify_ssl,
                  :api_url, :api_search, :status_url, :filters

    def initialize(config)
      @config = config
      @verify_ssl = true
      @debug = false
      @api_url = ''
      @api_search = ''
      @status_url = ''
      @filters = []
      @token = ''
      @token_exp = ''
    end

    def request_api
      validate_api_config
      build_api_uri
      log_api_search

      response = perform_request(@api_search.to_s)

      raise PDND::APIError.new(response.status, response.body.force_encoding('UTF-8')) unless response.success?

      puts "📡 Response: #{response.body}" if @debug
      [response.status, JSON.parse(response.body)]
    end

    def check_status
      validate_status_config

      response = perform_request(@status_url)

      puts "📡 Status response: #{response.body}" if @debug
      [response.status, JSON.parse(response.body)]
    end

    private

    def validate_api_config
      raise PDND::APIError.new(0, 'URL dell\'API assente!') if @api_url.to_s.strip.empty?
      raise PDND::APIError.new(0, 'Token assente!') if @token.to_s.strip.empty?
    end

    def validate_status_config
      raise PDND::APIError.new(0, 'URL per controllare lo stato della API assente!') if @status_url.to_s.strip.empty?
      raise PDND::APIError.new(0, 'Token assente!') if @token.to_s.strip.empty?
    end

    def build_api_uri
      parse_filters
      @api_search = URI(@api_url + (@filters ? "?#{@filters}" : ''))
    end

    def log_api_search
      puts "📡 API SEARCH: #{@api_search}" if @debug
    end

    def perform_request(url)
      conn = Faraday.new(url: url) do |faraday|
        faraday.ssl.verify = false unless @verify_ssl
        faraday.adapter Faraday.default_adapter
      end

      conn.get do |req|
        req.headers['Authorization'] = "Bearer #{@token}"
      end
    end

    def parse_filters
      case @filters
      when String
        @filters
      when Hash
        URI.encode_www_form(flatten_filter_hash(@filters))
      when Array
        @filters.join('&')
      else
        raise ArgumentError, '❌ I filtri devono essere una stringa, un hash o un array.'
      end
    end

    def flatten_filter_hash(hash)
      hash.each_with_object({}) do |(key, val), acc|
        if val.is_a?(Array)
          val.each do |v|
            acc["#{key}[]"] ||= []
            acc["#{key}[]"] << v
          end
        else
          acc[key] = val
        end
      end
    end
  end
end
