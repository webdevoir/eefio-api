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
  # TODO: this smells bad
  @block_numbers_to_fetch = []

  class << self
    # BlockImporterService.extract_blocks_from_raw_blocks
    # # => Starts at: 0. Ends at: the current latest Ethereum block number

    # BlockImporterService.extract_blocks_from_raw_blocks starting_block_number: 0,
    #                                                     ending_block_number:   2
    # # => Starts at: 0. Ends at: 2.

    # BlockImporterService.extract_blocks_from_raw_blocks starting_block_number: 1312
    # # => Starts at: 1312. Ends at: the latest Ethereum block number

    # BlockImporterService.extract_blocks_from_raw_blocks block_numbers:         [1, 2, 3, 5, 8]
    # # => Only fetches block numbers: 1, 2, 3, 5, 8

    # The block_numbers param takes precedence over starting/ending_block_number
    def extract_blocks_from_raw_blocks starting_block_number: nil, ending_block_number: nil, block_numbers: nil
      # Set fallback ending_block_number if it’s blank or zero
      ending_block_number = RawBlock.latest_block_number if ending_block_number.blank? || ending_block_number.zero?

      # Set fallback ending_block_number if it’s blank
      starting_block_number = 0 if starting_block_number.blank?

      # Don’t try to extract Blocks from RawBlocks that don’t exist in the database yet
      if block_numbers.blank? && ending_block_number > Block.latest_block_number
        RawBlock.latest_block_number
      else
        ending_block_number
      end

      # Setup batch of block numbers to work through
      @block_numbers_to_fetch = block_numbers&.uniq&.sort || (starting_block_number..ending_block_number).to_a

      # Go through all of those @block_numbers_to_fetch
      loop do
        # Get current block_number from the front of @block_numbers_to_fetch array
        block_number = @block_numbers_to_fetch.shift
        break if block_number.blank?

        # Find the RawBlock in the database
        raw_block = RawBlock.find_by(block_number: block_number)
        break if raw_block.blank?

        # Extract the block from the raw_blocks table and save to the blocks table
        BlockExtractorService.extract_block_from raw_block: raw_block

        # Check for extracted up to Blocks between
        # the last extracted up to Block block_number and the current block_number
        start_again  = Setting.blocks_extracted_up_to_block_number.content.to_i
        finish_again = block_number

        (start_again..finish_again).each do |block_number_again|
          check_blocks_extracted_up_to_block_number_setting block_number: block_number_again
        end

        # Once @block_numbers_to_fetch is empty [], quit!
        break if block_number.blank?
      end
    end

    def extract_block_from raw_block:
      puts "==> Extracting Block from RawBlock: #{raw_block.block_number}"

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
        block.send("#{block_attr}=", raw_block_content[raw_block_attr].from_hex)
      end

      # Block#published_at is a special case because it’s stored as DateTime object
      block.published_at = Time.zone.at raw_block_content[:timestamp].from_hex

      # Ensure that BOTH happen together:
      # The Block is created and the RawBlock is updated
      Block.transaction do
        # Save the Block to the database
        block.save
        puts "+++ Saved block: #{block.block_number}" if block.created_at.present?

        # Mark the associated RawBlock that its block data has been extract
        raw_block.update block_extracted_at: block.created_at
      end
    end

    def check_blocks_extracted_up_to_block_number_setting block_number:
      # Double check that it’s in the database
      block = Block.find_by block_number: block_number

      # If it is, update the setting for extracted up to Block block_number
      if block.present?
        update_blocks_extracted_up_to_block_number_setting! block_number: block.block_number
      else
        # If not, add that block_number to the front of the @block_numbers_to_fetch array to try fetching it again
        puts "!!! Block missing. Adding to range to try again. block_number: #{block_number}"
        @block_numbers_to_fetch.unshift block_number
      end
    end

    def blocks_all_extracted?
      RawBlock.latest_block_number == Setting.blocks_extracted_up_to_block_number.content.to_i
    end

    def clean_slate?
      Block.latest_block_number.zero? &&
        Setting.blocks_extracted_up_to_block_number.content.to_i.zero? &&
        Block.count.zero?
    end

    def update_blocks_extracted_up_to_block_number_setting! block_number:
      setting = Setting.blocks_extracted_up_to_block_number
      return if setting.content.to_i == block_number

      puts "+++ Updated Setting: blocks_extracted_up_to_block_number: #{block_number}"
      puts

      setting.update content: block_number
    end
  end
end
