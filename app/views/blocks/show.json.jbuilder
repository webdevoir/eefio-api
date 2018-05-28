json.prettify!

json.data do
  json.block do
    json.address @block.address
    json.block_number @block.block_number
    json.block_number_in_hex @block.block_number_in_hex
    json.difficulty @block.difficulty
    json.difficulty_in_hex @block.difficulty_in_hex
    json.extra_data @block.extra_data
    json.gas_limit @block.gas_limit
    json.gas_limit_in_hex @block.gas_limit_in_hex
    json.gas_used @block.gas_used
    json.gas_used_in_hex @block.gas_used_in_hex
    json.logs_bloom @block.logs_bloom
    json.miner_address @block.miner_address
    json.mix_hash @block.mix_hash
    json.nonce @block.nonce
    json.nonce_in_hex @block.nonce_in_hex
    json.parent_block_address @block.parent_block_address
    json.published_at @block.published_at
    json.published_at_in_hex @block.published_at_in_hex
    json.published_at_in_seconds_since_epoch @block.published_at_in_seconds_since_epoch
    json.receipts_root_address @block.receipts_root_address
    json.sha3_uncles @block.sha3_uncles
    json.size_in_bytes @block.size_in_bytes
    json.size_in_bytes_in_hex @block.size_in_bytes_in_hex
    json.state_root_address @block.state_root_address
    json.total_difficulty @block.total_difficulty
    json.total_difficulty_in_hex @block.total_difficulty_in_hex
    json.transactions_root_address @block.transactions_root_address
    json.uncles @block.uncles
  end
end
