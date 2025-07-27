# frozen_string_literal: true

# spec/pdnd-ruby-client/client_spec.rb

require 'spec_helper'
require 'pdnd-ruby-client/client'

# rubocop:disable Metrics/BlockLength
RSpec.describe PDND::Client do
  let(:config) { {} }
  let(:client) { described_class.new(config) }

  describe '#initialize' do
    it 'inizializza le variabili di istanza con valori predefiniti' do
      expect(client.token).to eq('')
      expect(client.token_exp).to eq('')
      expect(client.debug).to be false
      expect(client.verify_ssl).to be true
      expect(client.api_url).to eq('')
      expect(client.api_search).to eq('')
      expect(client.status_url).to eq('')
      expect(client.filters).to eq([])
    end
  end

  describe '#validate_api_config' do
    it 'solleva errore se api_url è vuoto' do
      client.token = 'abc'
      expect { client.send(:validate_api_config) }.to raise_error(PDND::APIError, /URL dell'API assente/)
    end

    it 'solleva errore se token è vuoto' do
      client.api_url = 'https://api.example.com'
      expect { client.send(:validate_api_config) }.to raise_error(PDND::APIError, /Token assente/)
    end
  end

  describe '#validate_status_config' do
    it 'solleva errore se status_url è vuoto' do
      client.token = 'abc'
      expect { client.send(:validate_status_config) }.to raise_error(PDND::APIError, /URL per controllare lo stato/)
    end

    it 'solleva errore se token è vuoto' do
      client.status_url = 'https://api.example.com/status'
      expect { client.send(:validate_status_config) }.to raise_error(PDND::APIError, /Token assente/)
    end
  end

  describe '#parse_filters' do
    it 'gestisce i filtri come stringa' do
      client.filters = 'foo=bar'
      expect(client.send(:parse_filters)).to eq('foo=bar')
    end

    it 'gestisce i filtri come array' do
      client.filters = ['foo=bar', 'baz=qux']
      expect(client.send(:parse_filters)).to eq('foo=bar&baz=qux')
    end

    it 'gestisce i filtri come hash con array' do
      client.filters = { category: %w[books music] }
      expect(client.send(:parse_filters)).to eq('category%5B%5D=books&category%5B%5D=music')
    end

    it 'solleva errore per tipo non valido' do
      client.filters = 123
      expect { client.send(:parse_filters) }.to raise_error(ArgumentError, /I filtri devono essere/)
    end
  end
end
# rubocop:enable Metrics/BlockLength
