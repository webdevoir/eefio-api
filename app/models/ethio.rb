class Ethio
  LICENSE           = 'CC0 / http://creativecommons.org/publicdomain/zero/1.0'.freeze
  API_URL           = (ENV['ETHIO_API_URL']           || 'https://api.ethio.app').freeze
  DOCUMENTATION_URL = (ENV['ETHIO_DOCUMENTATION_URL'] || 'https://ethio.app').freeze
  CONTRIBUTORS      = [
    'Shane Becker / https://veganstraightedge.com'
  ].freeze

  JSONAPI_VERSION     = '0'.freeze
  JSONAPI_DESCRIPTION = I18n.t('jsonapi.description').freeze
end
