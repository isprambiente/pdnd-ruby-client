# frozen_string_literal: true

# lib/pdnd_ruby_client/config_loader.rb

require 'json'
require 'dotenv/load'

# La classe Config viene inizializzata con un percorso verso un file di configurazione e una chiave di ambiente.
# Legge la configurazione dal file e la memorizza Hash.
module PDND
  # Carica la configurazione da un file JSON e restituisce i parametri per l'ambiente specificato.
  # Utilizzato per inizializzare i client PDND con le credenziali corrette.
  class ConfigLoader
    def self.load(path, env = 'produzione')
      config = JSON.parse(File.read(path))
      raise "❌ Ambiente '#{env}' non trovato" unless config[env]

      config[env].transform_keys(&:to_sym)
    end
  end
end
