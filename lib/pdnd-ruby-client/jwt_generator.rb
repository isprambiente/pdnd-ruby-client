# frozen_string_literal: true

require 'jwt'
require 'openssl'
require 'faraday'
require 'json'
require 'securerandom'
require_relative 'errors'

# @!group JWT Generator
# Classe responsabile della generazione di token JWT per autenticare le richieste verso l'API PDND.
# Firma il token con una chiave RSA (algoritmo RS256) e lo invia al server OAuth2 per ottenere un access token.
# @example
#   generator = PDND::JWTGenerator.new(config)
#   token, exp = generator.generate_token
# @attr [Hash] config Configurazione con parametri JWT
# @attr [String] env Ambiente di esecuzione ('produzione' o 'collaudo')
# @attr [Boolean] debug Flag per attivare il logging
# @attr [String] token Token di accesso ottenuto
# @attr [String] token_exp Data di scadenza del token
module PDND
  # @!group JWT Generator
  # Classe responsabile della generazione di token JWT per autenticare le richieste verso l'API PDND.
  # Firma il token con una chiave RSA (RS256) e lo invia al server OAuth2 per ottenere un access token.
  # @example
  #   generator = PDND::JWTGenerator.new(config)
  #   token, exp = generator.generate_token
  class JWTGenerator
    attr_accessor :env, :config, :debug, :issuer, :client_id, :priv_key, :priv_key_path,
                  :purpose_id, :kid, :endpoint, :audience, :assertion,
                  :token, :token_exp

    # @param config [Hash] Configurazione con chiavi come :issuer, :clientId, :privKeyPath, ecc.
    # @param env [String] Ambiente ('produzione' o 'collaudo')
    def initialize(config, env = 'produzione')
      @config     = config
      @env        = env
      @assertion  = ''
      @token      = ''
      @token_exp  = ''
      @debug      = false

      assign_config_values(config)
      configure_environment
    end

    # @return [Array<String>] Token di accesso e data di scadenza formattata
    def generate_token
      private_key = load_private_key
      @assertion = JWT.encode(build_payload, private_key, 'RS256', build_header)
      debug_log('🔐 Token JWT generato', @assertion)

      response_body = post_assertion
      @token = response_body['access_token']
      @token_exp = format_expiration(response_body['expires_in'])

      debug_log('✅ Token generato', @token)
      debug_log('✅ Token scadenza', @token_exp)

      [@token, @token_exp]
    end

    private

    def assign_config_values(config)
      @issuer        = config[:issuer]
      @client_id     = config[:clientId]
      @priv_key      = config[:privKey]
      @priv_key_path = config[:privKeyPath]
      @kid           = config[:kid]
      @purpose_id    = config[:purposeId]
    end

    # Imposta endpoint e audience in base all'ambiente
    def configure_environment
      if @env == 'collaudo'
        @endpoint = 'https://auth.uat.interop.pagopa.it/token.oauth2'
        @audience = 'auth.uat.interop.pagopa.it/client-assertion'
      else
        @endpoint = 'https://auth.interop.pagopa.it/token.oauth2'
        @audience = 'auth.interop.pagopa.it/client-assertion'
      end
    end

    # @return [OpenSSL::PKey::RSA] Chiave privata RSA
    # @raise [PDND::ConfigError] Se la chiave è invalida o il file non esiste
    def load_private_key
      key = nil

      if @priv_key.to_s.strip != ''
        key = @priv_key
        debug_log('✅ Priv Key acquisita manualmente', '**********')
      elsif @priv_key_path.to_s.strip != ''
        key = File.read(@priv_key_path)
        debug_log('✅ Priv Key acquisita da file', '**********')
      else
        raise PDND::ConfigError, '❌ Nessuna chiave privata o percorso fornito'
      end

      OpenSSL::PKey::RSA.new(key)
    rescue OpenSSL::PKey::RSAError => e
      raise PDND::ConfigError, "❌ Chiave privata non valida: #{e.message}"
    rescue Errno::ENOENT => e
      raise PDND::ConfigError, "❌ File della chiave non trovato: #{e.message}"
    end

    # @return [Hash] Payload JWT con claim standard
    def build_payload
      issued_at = Time.now.to_i
      {
        iss: @issuer,
        sub: @client_id,
        aud: @audience,
        purposeId: @purpose_id,
        jti: SecureRandom.hex(16),
        iat: issued_at,
        exp: issued_at + 300
      }
    end

    # @return [Hash] Header JWT con chiave e algoritmo
    def build_header
      {
        kid: @kid,
        alg: 'RS256',
        typ: 'JWT'
      }
    end

    # @return [Hash] Corpo della risposta OAuth2 con access token
    # @raise [PDND::APIError] Se la risposta HTTP è un errore
    def post_assertion
      response = send_assertion_request
      raise_api_error(response) unless response.success?
      JSON.parse(response.body)
    end

    # @return [Faraday::Response] Risposta HTTP dal server OAuth2
    def send_assertion_request
      Faraday.post(@endpoint) do |req|
        req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
        req.headers['Accept'] = '*'
        req.body = encoded_assertion_body
      end
    end

    def encoded_assertion_body
      URI.encode_www_form(
        {
          client_id: @client_id,
          client_assertion: @assertion,
          client_assertion_type: 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer',
          grant_type: 'client_credentials'
        }
      )
    end

    # @param response [Faraday::Response]
    # @raise [PDND::APIError] con messaggio dettagliato
    def raise_api_error(response)
      parsed = JSON.parse(response.body)
      message = parsed['error_description'] || parsed['error'] || response.body
      raise PDND::APIError.new(response.status, message)
    end

    # @param expires_in [Integer] Secondi di validità
    # @return [String] Timestamp formattato
    def format_expiration(expires_in)
      Time.at(Time.now.to_i + expires_in).strftime('%Y-%m-%d %H:%M:%S')
    end

    # @param title [String] Titolo del log
    # @param value [String] Contenuto da stampare
    def debug_log(title, value)
      puts "\n#{title}:\n#{value}" if @debug
    end
  end
end
