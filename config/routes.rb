Rails.application.routes.draw do
  # /
  # List available endpoints, license info, documentation links, contribtuors, etc
  root to: 'root#index', defaults: { format: :json }

  # /blocks/latest find by biggest block number
  # /blocks/123    find by block number
  # /blocks/0xACAB find by block address
  get 'blocks/:id', to: 'blocks#show', as: :block, defaults: { format: :json }

  ### Sidekiq... ###
  # /sidekiq for job queue admin
  #
  # Protect against timing attacks:
  # - See https://codahale.com/a-lesson-in-timing-attacks
  # - See https://thisdata.com/blog/timing-attacks-against-string-comparison
  # - Use & (do not use &&) so that it doesn’t short circuit.
  # - Use digests to stop length information leaking
  #   (see also ActiveSupport::SecurityUtils.variable_size_secure_compare)
  require 'sidekiq/web'

  if Rails.env.production?
    Sidekiq::Web.use Rack::Auth::Basic do |username, password|
      ActiveSupport::SecurityUtils.secure_compare(
        ::Digest::SHA256.hexdigest(username),
        ::Digest::SHA256.hexdigest(ENV['SIDEKIQ_USERNAME'])
      ) & ActiveSupport::SecurityUtils.secure_compare(
        ::Digest::SHA256.hexdigest(password),
        ::Digest::SHA256.hexdigest(ENV['SIDEKIQ_PASSWORD'])
      )
    end
  end

  mount Sidekiq::Web, at: '/sidekiq'
  ### ...Sidekiq ###
end
