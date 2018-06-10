class Ethio
  LICENSE = 'CC0 / http://creativecommons.org/publicdomain/zero/1.0'.freeze

  DOCUMENTATION_URL = ENV.fetch('ETHIO_DOCUMENTATION_URL') do
    Rails.env.development? ? 'http://localhost:3000' : 'https://ethio.app'
  end.freeze

  API_URL = ENV.fetch('ETHIO_API_BASE_URL') do
    Rails.env.development? ? 'http://localhost:3000' : 'https://api.ethio.app'
  end.freeze

  CONTRIBUTORS = [
    '# Human Name | # GitHub username  | # Personal Website (optional)',
    'Shane Becker | @veganstraightedge | https://veganstraightedge.com'
  ].freeze

  JSONAPI_VERSION     = '0'.freeze
  JSONAPI_DESCRIPTION = I18n.t('jsonapi.description').freeze
end
