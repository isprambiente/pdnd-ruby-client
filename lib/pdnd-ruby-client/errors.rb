# frozen_string_literal: true

# 📎 Modulo contenente le classi di errore personalizzate per PDND Ruby Client.
module PDND
  # Errore generico
  class Error < StandardError
    def initialize(msg = 'Errore generico PDND')
      super
    end
  end

  # Errore specifico per token scaduti o non validi
  class TokenExpiredError < Error
    def initialize
      super('❌ Il token è scaduto o non valido')
    end
  end

  # Errore di configurazione
  class ConfigError < Error
    def initialize(msg = '❌ Configurazione non valida')
      super
    end
  end

  # Errore restituito dalle API, con codice e corpo inclusi
  class APIError < StandardError
    def initialize(status, body)
      super(body.dup.force_encoding('UTF-8'))
      @status = status
    end
  end
end
