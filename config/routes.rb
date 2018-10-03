Rails.application.routes.draw do
  # /
  # List available endpoints, license info, documentation links, contribtuors, etc
  root to: 'root#index', defaults: { format: :json }

  # Show a Block
  # /blocks/latest find by biggest block number
  # /blocks/123    find by block number
  # /blocks/0xACAB find by block address
  get 'blocks/:id', to: 'blocks#show', as: :block, defaults: { format: :json }

  # Show a Block’s raw content from an Ethereum node’s JSON-RPC
  # /blocks/latest/raw find by biggest block number
  # /blocks/123/raw    find by block number
  # /blocks/0xACAB/raw find by block address
  get 'blocks/:id/raw', to: 'blocks#raw', as: :raw_block, defaults: { format: :json }

  # Show a Transaction
  # /transactions/0xACAB find by Transaction address
  # /transactions/latest find by biggest Block number and biggest index_on_block on Transaction
  get 'transactions/:id', to: 'transactions#show', as: :transaction, defaults: { format: :json }

  # Show a Transaction’s raw content from an Ethereum node’s JSON-RPC
  # /transactions/0xACAB/raw find by Transaction address
  # /transactions/latest/raw find by biggest Block number and biggest index_on_block on Transaction
  get 'transactions/:id/raw', to: 'transactions#raw', as: :raw_transaction, defaults: { format: :json }

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
