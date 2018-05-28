Rails.application.routes.draw do
  get 'blocks/latest', to: 'blocks#show_latest', as: :latest_block
end
