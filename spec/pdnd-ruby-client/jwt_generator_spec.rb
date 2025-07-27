# frozen_string_literal: true

# spec/pdnd-ruby-client/jwt_generator_spec.rb

require 'spec_helper'
require 'pdnd-ruby-client/jwt_generator'

RSpec.describe PDND::JWTGenerator do
  let(:config) do
    {
      issuer: 'https://example.com',
      clientId: 'my-client-id',
      privKeyPath: 'spec/fixtures/private_key.pem',
      kid: 'abc123',
      purposeId: 'xyz456'
    }
  end

  subject { described_class.new(config, 'produzione') }

  describe '#initialize' do
    it 'inizializza correttamente le variabili di istanza' do
      expect(subject.instance_variable_get(:@env)).to eq('produzione')
      expect(subject.instance_variable_get(:@issuer)).to eq(config[:issuer])
    end
  end

  describe '#encoded_assertion_body' do
    it 'restituisce un corpo valido per la richiesta token' do
      subject.instance_variable_set(:@assertion, 'mocked_jwt')
      body = subject.send(:encoded_assertion_body)
      expect(body).to include('client_id=my-client-id')
      expect(body).to include('client_assertion=mocked_jwt')
    end
  end
end
