# frozen_string_literal: true

# spec/pdnd_ruby_client/config_loader_spec.rb

require 'spec_helper'
require 'pdnd_ruby_client/config_loader'
require 'json'

# rubocop:disable Metrics/BlockLength
RSpec.describe PDND::ConfigLoader do
  let(:valid_json) do
    {
      'produzione' => {
        'issuer' => 'https://example.com',
        'clientId' => 'my-client-id',
        'privKeyPath' => '/path/to/key.pem',
        'kid' => 'abc123',
        'purposeId' => 'xyz456'
      }
    }.to_json
  end

  let(:config_path) { 'spec/fixtures/test_config.json' }

  before do
    File.write(config_path, valid_json)
  end

  after do
    File.delete(config_path)
  end

  it 'carica correttamente la configurazione come hash con simboli' do
    config = described_class.load(config_path)
    expect(config).to be_a(Hash)
    expect(config[:issuer]).to eq('https://example.com')
    expect(config.keys).to include(:clientId, :privKeyPath, :kid)
  end

  it 'solleva errore se l’ambiente non esiste' do
    expect do
      described_class.load(config_path, 'fake_env')
    end.to raise_error(/Ambiente/)
  end
end
# rubocop:enable Metrics/BlockLength
