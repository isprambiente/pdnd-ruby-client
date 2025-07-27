# frozen_string_literal: true

require 'pdnd_ruby_client'

RSpec.describe PDND::ClientVersion do
  it 'ha una VERSION definita' do
    expect(PDND::ClientVersion::VERSION).not_to be_nil
  end

  it 'segue semver (x.y.z)' do
    expect(PDND::ClientVersion::VERSION).to match(/^\d+\.\d+\.\d+$/)
  end
end
