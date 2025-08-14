# frozen_string_literal: true

# lib/pdnd_ruby_client/token_manager.rb

# Questa classe è responsabile del caricamento e salvataggio del token su file esterno.
module PDND
  # Gestisce caricamento e salvataggio del token su file esterno.
  class TokenManager
    attr_reader :token, :exp, :path

    def initialize(path = 'tmp/pdnd_token.json')
      @path = path
      @token = nil
      @exp = nil
    end

    def load
      return unless File.exist?(@path)

      data = JSON.parse(File.read(@path))
      @token = data['token']
      @exp = data['exp']
      [@token, @exp]
    end

    def save(token, exp)
      @token = token
      @exp = exp
      File.write(@path, { token: token, exp: exp }.to_json)
    end

    def valid?
      @token.present? && @exp.present? && (Time.now.to_i < Time.new(@exp).to_i)
    end
  end
end
