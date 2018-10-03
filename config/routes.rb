Rails.application.routes.draw do
  # /
  # List available endpoints, license info, documentation links, contribtuors, etc
  root to: 'root#index', defaults: { format: :json }

  # Show a Block
  # /blocks/latest find by biggest block number
  # /blocks/0xACAB find by block address
  # /blocks/123    find by block number
  get 'blocks/:id', to: 'blocks#show', as: :block, defaults: { format: :json }

  # Show a Block’s raw content from an Ethereum node’s JSON-RPC
  # /blocks/latest/raw find by biggest block number
  # /blocks/0xACAB/raw find by block address
  # /blocks/123/raw    find by block number
  get 'blocks/:id/raw', to: 'blocks#raw', as: :raw_block, defaults: { format: :json }

  # Show a Block’s Transactions
  # /blocks/latest/raw find by biggest block number
  # /blocks/0xACAB/raw find by block address
  # /blocks/123/raw    find by block number
  get 'blocks/:id/transactions', to: 'blocks#transactions', as: :block_transactions, defaults: { format: :json }

  # Show a Transaction
  # /transactions/latest find by biggest Block number and biggest index_on_block on Transaction
  # /transactions/0xACAB find by Transaction address
  get 'transactions/:id', to: 'transactions#show', as: :transaction, defaults: { format: :json }

  # Show a Transaction’s raw content from an Ethereum node’s JSON-RPC
  # /transactions/latest/raw find by biggest Block number and biggest index_on_block on Transaction
  # /transactions/0xACAB/raw find by Transaction address
  get 'transactions/:id/raw', to: 'transactions#raw', as: :raw_transaction, defaults: { format: :json }
end
