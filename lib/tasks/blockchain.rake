namespace :eefio do
  namespace :blockchain do
    desc 'Sync blocks from the Ethereum blockchain into the raw_blocks database table'
    task sync: :environment do
      latest_raw_block_number = RawBlock.latest_block_number
      in_sync_block_number    = Setting.raw_blocks_synced_at_block_number.content.to_i

      puts
      puts '___ Syncing blockchain…'
      puts
      puts "___ Latest RawBlock block_number:       #{latest_raw_block_number}"
      puts "___ Last in sync RawBlock block_number: #{in_sync_block_number}"
      puts

      # First time run!
      if BlockImporterService.clean_slate?
        starting_block_number = 0
        ending_block_number   = Ethereum.fetch_latest_block_number

        puts "___ Fetching RawBlocks for block numbers: #{starting_block_number} - #{ending_block_number}"
        puts

        BlockImporterService.fetch_blocks_from_blockchain starting_block_number: starting_block_number,
                                                          ending_block_number:   ending_block_number
      end

      # Non-first time runs:
      # First things first, self-heal existing RawBlocks table
      # before syncing new RawBlocks from blockchain
      unless BlockImporterService.raw_blocks_in_sync?
        # Get in sync RawBlock setting, and build range to check within
        starting_block_number, ending_block_number = [in_sync_block_number, latest_raw_block_number].sort

        # Find the missing RawBlocks by finding the difference between
        # the range of RawBlocks min/max and the actual RawBlocks in the database
        saved_block_numbers = RawBlock.pluck(:block_number).sort.uniq
        saved_block_numbers_range = (starting_block_number..ending_block_number).to_a

        # Update the in sync setting as much as possible with the RawBlocks already saved
        saved_block_numbers_range.each do |block_number|
          BlockImporterService.check_raw_blocks_synced_at_block_number_setting block_number: block_number
        end

        # Find the missing RawBlocks by finding the difference between
        # the range of RawBlocks min/max and the actual RawBlocks in the database
        starting_block_number     = Setting.raw_blocks_synced_at_block_number.content.to_i
        ending_block_number       = RawBlock.latest_block_number
        saved_block_numbers       = RawBlock.pluck(:block_number).sort.uniq
        saved_block_numbers_range = (starting_block_number..ending_block_number).to_a
        block_numbers_to_fetch    = saved_block_numbers_range - saved_block_numbers

        loop do
          # Go through all of those block_numbers_to_fetch
          break if block_numbers_to_fetch.blank?

          puts "___ Fetching RawBlocks for block numbers: #{block_numbers_to_fetch.length}"
          puts
          BlockImporterService.fetch_blocks_from_blockchain block_numbers: block_numbers_to_fetch
          puts
        end
      end

      # Non-first time runs:
      # Sync all of the RawBlocks from the blockchain
      loop do
        break if BlockImporterService.raw_blocks_synced_with_blockchain?

        puts
        puts '___ Eefio RawBlocks not in sync with the Ethereum blockchain'
        puts

        starting_block_number = Setting.raw_blocks_synced_at_block_number.content.to_i + 1
        ending_block_number   = Ethereum.fetch_latest_block_number

        puts "___ Fetching RawBlocks for block numbers: #{starting_block_number} - #{ending_block_number}"
        puts

        BlockImporterService.fetch_blocks_from_blockchain starting_block_number: starting_block_number,
                                                          ending_block_number:   ending_block_number
      end

      # Once RawBlocks is in sync with the blockchain, then quit!
      if BlockImporterService.raw_blocks_synced_with_blockchain?
        synced_block_number = Setting.raw_blocks_synced_at_block_number.content.to_i
        puts
        puts "___ FINISHED! Current in sync RawBlock: #{synced_block_number}"
      end

      puts
    end
  end
end
