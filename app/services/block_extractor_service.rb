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
      raw_block_content = JSON.parse(raw_block.content).with_indifferent_access

      # Create a new empty Block object
      block = Block.new

      # Keys (on the left) are Block attributes (columns in the database on the blocks table)
      # Values (on the right) are RawBlock.content attributes (keys in the JSON blob)
      # Walk with each pair and save the value from the JSON blob into the new Block object
      {
        address:                                    :hash,
        block_number_in_hex:                        :number,
        difficulty_in_hex:                          :difficulty,
        extra_data:                                 :extraData,
        gas_limit_in_hex:                           :gasLimit,
        gas_used_in_hex:                            :gasUsed,
        logs_bloom:                                 :logsBloom,
        miner_address:                              :miner,
        mix_hash:                                   :mixHash,
        nonce_in_hex:                               :nonce,
        parent_block_address:                       :parentHash,
        published_at_in_seconds_since_epoch_in_hex: :timestamp,
        receipts_root_address:                      :receiptsRoot,
        sha3_uncles:                                :sha3Uncles,
        size_in_bytes_in_hex:                       :size,
        state_root_address:                         :stateRoot,
        total_difficulty_in_hex:                    :totalDifficulty,
        transactions_root_address:                  :transactionsRoot,
        uncles:                                     :uncles
      }.each do |block_attr, raw_block_attr|
        block.send("#{block_attr}=", raw_block_content[raw_block_attr])
      end

      # Keys (on the left) are Block attributes (columns in the database on the blocks table)
      # Values (on the right) are RawBlock.content attributes (keys in the JSON blob)
      # Walk with each pair and save the value from the JSON blob into the new Block object
      {
        block_number:                        :number,
        difficulty:                          :difficulty,
        gas_limit:                           :gasLimit,
        gas_used:                            :gasUsed,
        nonce:                               :nonce,
        published_at_in_seconds_since_epoch: :timestamp,
        size_in_bytes:                       :size,
        total_difficulty:                    :totalDifficulty
      }.each do |block_attr, raw_block_attr|
        block.send("#{block_attr}=", raw_block_content[raw_block_attr].from_hex.to_i)
      end

      # Block#published_at is a special case because it’s stored as DateTime object
      block.published_at = Time.zone.at raw_block_content[:timestamp].from_hex

      # Ensure that BOTH happen together:
      # The Block is created and the RawBlock is updated
      Block.transaction do
        # Save the Block to the database
        block.save

        # Mark the associated RawBlock that its block data has been extract
        raw_block.update block_extracted_at: block.created_at
      end
    end
  end
end
