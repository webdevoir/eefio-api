Rails.application.routes.draw do
  get 'blocks/latest', to: 'blocks#show_latest', as: :latest_block

  # /blocks/123    find by block number
  # /blocks/0xACAB find by block address
  get 'blocks/:id', to: 'blocks#show', as: :block
end
