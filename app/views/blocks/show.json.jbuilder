json.prettify!

json.links do
  json.merge! @links
end

json.data do
  json.block do
    json.address @block.address

    json.block_number @block.block_number.to_i
    json.block_number_in_hex @block.block_number_in_hex

    json.difficulty @block.difficulty.to_i
    json.difficulty_in_hex @block.difficulty_in_hex

    json.extra_data @block.extra_data

    json.gas_limit @block.gas_limit.to_i
    json.gas_limit_in_hex @block.gas_limit_in_hex

    json.gas_used @block.gas_used.to_i
    json.gas_used_in_hex @block.gas_used_in_hex

    json.logs_bloom @block.logs_bloom
    json.miner_address @block.miner_address
    json.mix_hash @block.mix_hash
    json.nonce @block.nonce.to_i
    json.nonce_in_hex @block.nonce_in_hex
    json.parent_block_address @block.parent_block_address

    json.published_at @block.published_at.iso8601
    json.published_at_in_seconds_since_epoch_in_hex @block.published_at_in_seconds_since_epoch_in_hex
    json.published_at_in_seconds_since_epoch @block.published_at_in_seconds_since_epoch.to_i

    json.receipts_root_address @block.receipts_root_address
    json.sha3_uncles @block.sha3_uncles

    json.size_in_bytes @block.size_in_bytes.to_i
    json.size_in_bytes_in_hex @block.size_in_bytes_in_hex

    json.state_root_address @block.state_root_address

    json.total_difficulty @block.total_difficulty.to_i
    json.total_difficulty_in_hex @block.total_difficulty_in_hex

    json.transactions_root_address @block.transactions_root_address
    json.uncles @block.uncles
  end
end

json.meta do
  json.description   Eefio::API_DESCRIPTION
  json.version       Eefio::API_VERSION
  json.license       Eefio::LICENSE
  json.url           Eefio::API_URL
  json.contributors  Eefio::CONTRIBUTORS
  json.documentation @documentation
  json.contact       Eefio::CONTACT_INFO
end

json.jsonapi do
  json.version     Eefio::JSONAPI_VERSION
  json.description Eefio::JSONAPI_DESCRIPTION
end
