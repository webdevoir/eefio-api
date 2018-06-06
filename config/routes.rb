Rails.application.routes.draw do
  # /
  # List available endpoints, license info, documentation links, contribtuors, etc
  root to: 'root#index', defaults: { format: :json }

  # /blocks/latest find by biggest block number
  # /blocks/123    find by block number
  # /blocks/0xACAB find by block address
  get 'blocks/:id', to: 'blocks#show', as: :block, defaults: { format: :json }
end
