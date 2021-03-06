class Eefio
  API_VERSION         = '0.0.1.ALPHA'.freeze
  JSONAPI_VERSION     = '0'.freeze
  JSONAPI_DESCRIPTION = I18n.t('jsonapi.description').freeze
  LICENSE             = 'CC0 / http://creativecommons.org/publicdomain/zero/1.0'.freeze
  DOCUMENTATION_URL   = (ENV['EEFIO_DOCUMENTATION_URL'] || 'https://eefio.com/docs').freeze

  API_DESCRIPTION = 'Eefio is a REST API for the Ethereum blockchain that aims to be humane in its design, usage, and documentation.'.freeze

  API_URL = ENV.fetch('EEFIO_API_BASE_URL') do
    Rails.env.development? ? 'http://localhost:3000' : 'https://api.eefio.com'
  end.freeze

  CONTRIBUTORS = [
    I18n.t('api.contributors.header'),
    'Shane Becker | @veganstraightedge | https://veganstraightedge.com'
  ].freeze

  CONTACT_INFO = [
    'https://github.com/eefio/eefio-api',
    'https://twitter.com/eefioapi'
  ].freeze
end
