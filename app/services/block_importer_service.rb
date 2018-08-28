class BlockImporterService
  class << self
    # BlockImporterService.fetch_blocks_from_blockchain
    # # => Starts at: 0. Ends at: the current latest Ethereum block number

    # BlockImporterService.fetch_blocks_from_blockchain starting_block_number: 0,
    #                                                   ending_block_number:   2
    # # => Starts at: 0. Ends at: 2.

    # BlockImporterService.fetch_blocks_from_blockchain starting_block_number: 1312
    # # => Starts at: 1312. Ends at: the latest Ethereum block number

    # BlockImporterService.fetch_blocks_from_blockchain block_numbers:         [1, 2, 3, 5, 8]
    # # => Only fetches block numbers: 1, 2, 3, 5, 8

    # The block_numbers param takes precedence over starting/ending_block_number
    def fetch_blocks_from_blockchain starting_block_number: nil, ending_block_number: nil, block_numbers: nil
      # Set fallback ending_block_number if it’s blank or zero
      ending_block_number = Ethereum.fetch_latest_block_number if ending_block_number.blank? || ending_block_number.zero?

      # Set fallback ending_block_number if it’s blank
      starting_block_number = 0 if starting_block_number.blank?

      # Don’t try to fetch blocks that don’t exist on the blockchain yet
      if block_numbers.blank? && ending_block_number > RawBlock.latest_block_number
        RawBlock.latest_block_number
      else
        ending_block_number
      end

      # Setup batch of block numbers to work through
      block_numbers_to_fetch = block_numbers&.uniq&.sort || (starting_block_number..ending_block_number).to_a

      # Go through all of those block_numbers_to_fetch
      loop do
        # Get current block_number from the front of block_numbers_to_fetch array
        block_number = block_numbers_to_fetch.shift
        break if block_number.blank?

        # Fetch the RawBlock from the blockchain
        begin
          blockchain_block = Ethereum.get_block block_number: block_number
        rescue Timeout::Error
          puts "!!! Network request timed out. Adding to range to try again. block_number: #{block_number}"
          block_numbers_to_fetch.unshift block_number
          next
        end

        # Save the blockchain_block to the raw_blocks table in the database
        create_raw_block_from blockchain_block: blockchain_block

        # Check for in sync block RawBlocks between
        # the last in sync RawBlock block_number and the current block_number
        start_again  = Setting.raw_blocks_synced_at_block_number.content.to_i
        finish_again = block_number

        (start_again..finish_again).each do |block_number_again|
          # Double check that it’s in the database
          raw_block = RawBlock.find_by block_number: block_number_again

          # If it is, update the setting for in sync RawBlock block_number
          if raw_block.present?
            update_raw_blocks_synced_at_block_number_setting! block_number: raw_block.block_number
          else
            # If not, add that block_number to the front of the block_numbers_to_fetch array to try fetching it again
            puts "!!! RawBlock missing. Adding to range to try again. block_number: #{block_number_again}"
            block_numbers_to_fetch.unshift block_number_again
          end
        end

        # Once block_numbers_to_fetch is empty [], quit!
        break if block_number.blank?
      end
    end

    def create_raw_block_from blockchain_block:
      # Save the blockchain_block to the raw_blocks table in the database
      raw_block = RawBlock.create block_number: blockchain_block.block_number, content: blockchain_block.raw_data.to_json
      puts "+++ Saved block: #{raw_block.block_number}" if raw_block.created_at.present?
    end

    def update_raw_blocks_synced_at_block_number_setting! block_number:
      setting = Setting.raw_blocks_synced_at_block_number
      return if setting.content.to_i == block_number

      puts "+++ Updating Setting: raw_blocks_synced_at_block_number: #{block_number}"

      setting.update content: block_number
    end
  end
end
