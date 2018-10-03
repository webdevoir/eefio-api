json.prettify!

json.links do
  json.merge! @links
end

json.data do
  json.block do
    json.address @block.address
    json.block_number @block.block_number
    json.block_number_in_hex @block.block_number_in_hex

    json.transaction do
      json.address @transaction.address

      json.to @transaction.to
      json.from @transaction.from

      json.eth_sent_in_wei @transaction.eth_sent_in_wei
      json.eth_sent_in_wei_in_hex @transaction.eth_sent_in_wei_in_hex

      json.gas_price_in_wei @transaction.gas_price_in_wei
      json.gas_price_in_wei_in_hex @transaction.gas_price_in_wei_in_hex
      json.gas_provided @transaction.gas_provided
      json.gas_provided_in_hex @transaction.gas_provided_in_hex

      json.index_on_block @transaction.index_on_block
      json.index_on_block_in_hex @transaction.index_on_block_in_hex

      json.input @transaction.input

      json.nonce @transaction.nonce
      json.nonce_in_hex @transaction.nonce_in_hex

      json.published_at @transaction.published_at
      json.published_at_in_seconds_since_epoch @transaction.published_at_in_seconds_since_epoch
      json.published_at_in_seconds_since_epoch_in_hex @transaction.published_at_in_seconds_since_epoch_in_hex

      json.r @transaction.r
      json.s @transaction.s
      json.v @transaction.v
      json.v_in_hex @transaction.v_in_hex
    end
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
