# TODO: why doesn’t this autoload from /app/lib
class String
  # Usage: '0xACAB'.from_hex #=> 44203
  def from_hex
    to_i 16
  end
end

# TODO: why doesn’t this autoload from /app/lib
class Integer
  # Usage: 8675309.to_hex #=> 0x845fed
  def to_hex
    '0x' + to_s(16)
  end
end

class BlockExtractorService
  class << self
    def extract_block_from raw_block:
      # Work with just the RawBlock’s content JSON blob
      raw_block = JSON.parse(raw_block.content).with_indifferent_access
      puts raw_block

      block = Block.new

      block.address = raw_block[:hash]

      block.block_number        = raw_block[:number].from_hex
      block.block_number_in_hex = raw_block[:number]

      block.difficulty        = raw_block[:difficulty].from_hex
      block.difficulty_in_hex = raw_block[:difficulty]

      block.extra_data = raw_block[:extraData]

      block.gas_limit        = raw_block[:gasLimit].from_hex
      block.gas_limit_in_hex = raw_block[:gasLimit]

      block.gas_used        = raw_block[:gasUsed].from_hex
      block.gas_used_in_hex = raw_block[:gasUsed]

      block.logs_bloom = raw_block[:logsBloom]

      block.miner_address = raw_block[:miner]
      block.mix_hash = raw_block[:mixHash]

      block.nonce        = raw_block[:nonce].from_hex
      block.nonce_in_hex = raw_block[:nonce]

      block.parent_block_address = raw_block[:parentHash]

      block.published_at                        = Time.at raw_block[:timestamp].from_hex
      block.published_at_in_hex                 = raw_block[:timestamp]
      block.published_at_in_seconds_since_epoch = raw_block[:timestamp].from_hex

      block.receipts_root_address = raw_block[:receiptsRoot]
      block.sha3_uncles   = raw_block[:sha3Uncles]

      block.size_in_bytes        = raw_block[:size].from_hex
      block.size_in_bytes_in_hex = raw_block[:size]

      block.state_root_address = raw_block[:stateRoot]

      block.total_difficulty        = raw_block[:totalDifficulty].from_hex
      block.total_difficulty_in_hex = raw_block[:totalDifficulty]

      block.transactions_root_address = raw_block[:transactionsRoot]
      block.uncles = raw_block[:uncles]

      pp block
      block.save
    end
  end
end
