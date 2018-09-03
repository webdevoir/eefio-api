namespace :eefio do
  namespace :blocks do
    desc 'Extracts blocks from the raw_blocks table into the blocks table'
    task extract: :environment do
      latest_block_number           = Block.latest_block_number
      latest_extracted_block_number = Setting.blocks_extracted_up_to_block_number.content.to_i

      puts
      puts '___ Extracting Blocks…'
      puts
      puts "___ Latest Block block_number:         #{latest_block_number}"
      puts "___ Last extracted Block block_number: #{latest_extracted_block_number}"
      puts

      # First time run!
      if BlockExtractorService.clean_slate?
        starting_block_number = 0
        ending_block_number   = RawBlock.latest_block_number

        puts "___ Extracting Blocks for block numbers: #{starting_block_number} - #{ending_block_number}"
        puts

        BlockExtractorService.extract_blocks_from_raw_blocks starting_block_number: starting_block_number,
                                                             ending_block_number:   ending_block_number
      end

      # Non-first time runs:
      # First things first, self-heal existing RawBlocks table
      # before syncing new RawBlocks from blockchain
      unless BlockExtractorService.blocks_all_extracted?
        # Get in sync RawBlock setting, and build range to check within
        starting_block_number, ending_block_number = [latest_extracted_block_number, latest_block_number].sort

        # Find the missing RawBlocks by finding the difference between
        # the range of RawBlocks min/max and the actual RawBlocks in the database
        saved_block_numbers_range = (starting_block_number..ending_block_number).to_a

        # Update the in sync setting as much as possible with the RawBlocks already saved
        saved_block_numbers_range.each do |block_number|
          BlockExtractorService.check_blocks_extracted_up_to_block_number_setting block_number: block_number
        end

        # Find the missing RawBlocks by finding the difference between
        # the range of RawBlocks min/max and the actual RawBlocks in the database
        starting_block_number     = Setting.blocks_extracted_up_to_block_number.content.to_i
        ending_block_number       = RawBlock.latest_block_number
        saved_block_numbers       = RawBlock.pluck(:block_number).sort.uniq
        saved_block_numbers_range = (starting_block_number..ending_block_number).to_a
        block_numbers_to_fetch    = saved_block_numbers_range - saved_block_numbers

        loop do
          # Go through all of those block_numbers_to_fetch
          break if block_numbers_to_fetch.blank?

          puts "___ Fetching RawBlocks for block numbers: #{block_numbers_to_fetch.length}"
          puts
          BlockExtractorService.extract_blocks_from_raw_blocks block_numbers: block_numbers_to_fetch
          puts
        end
      end

      # Non-first time runs:
      # Extract all of the Blocks from RawBlocks table
      loop do
        break if BlockExtractorService.blocks_all_extracted?

        puts
        puts '___ Not all Eefio RawBlocks are extracted to Blocks '
        puts

        starting_block_number = Setting.blocks_extracted_up_to_block_number.content.to_i + 1
        ending_block_number   = RawBlock.latest_block_number

        starting_block_number, ending_block_number = [starting_block_number, ending_block_number].sort

        puts "___ Extracting Blocks for block numbers: #{starting_block_number} - #{ending_block_number}"
        puts

        BlockExtractorService.extract_blocks_from_raw_blocks starting_block_number: starting_block_number,
                                                             ending_block_number:   ending_block_number
      end

      # Once RawBlocks is in sync with the blockchain, then quit!
      if BlockExtractorService.blocks_all_extracted?
        latest_extracted_block_number = Setting.blocks_extracted_up_to_block_number.content.to_i
        puts
        puts "___ FINISHED! Latest extracted Block: #{latest_extracted_block_number}"
      end

      puts
    end
  end
end
