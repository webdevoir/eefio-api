Rails.application.routes.draw do
  # /blocks/latest find by biggest block number
  # /blocks/123    find by block number
  # /blocks/0xACAB find by block address
  get 'blocks/:id', to: 'blocks#show', as: :block, defaults: { format: :json }
end
