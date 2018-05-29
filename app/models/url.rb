class URL
  ETHIO_API_BASE_URL = ENV.fetch('ETHIO_API_BASE_URL') do
    Rails.env.development? ? 'http://localhost:3000' : 'https://api.ethio.app'
  end.freeze
end