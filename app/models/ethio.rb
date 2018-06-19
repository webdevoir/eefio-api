class Ethio
  API_VERSION         = 'ALPHA'.freeze
  JSONAPI_VERSION     = '0'.freeze
  JSONAPI_DESCRIPTION = I18n.t('jsonapi.description').freeze
  LICENSE             = 'CC0 / http://creativecommons.org/publicdomain/zero/1.0'.freeze
  DOCUMENTATION_URL   = (ENV['ETHIO_DOCUMENTATION_URL'] || 'https://ethio.app/docs').freeze

  API_URL = ENV.fetch('ETHIO_API_BASE_URL') do
    Rails.env.development? ? 'http://localhost:3000' : 'https://api.ethio.app'
  end.freeze

  CONTRIBUTORS = [
    I18n.t('api.contributors.header'),
    'Shane Becker | @veganstraightedge | https://veganstraightedge.com'
  ].freeze
end
