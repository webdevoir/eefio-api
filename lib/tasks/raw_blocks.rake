namespace :eefio do
  namespace :raw_blocks do
    desc 'Starts at the start and finds missing raw_blocks in the database, fetches them from blockchain'
    task fetch_missing: :environment do
      # Get in sync RawBlock setting
      synced_block_number = Setting.find_by name: 'raw_blocks_synced_at_block_number'

      # Build range to check within
      start  = synced_block_number.content.to_i
      finish = RawBlock.latest_block_number

      # Fallback to something for development and testing
      finish = 20 if Rails.env.development? && finish.zero?

      # Find the missing RawBlocks by finding the difference between
      # the range of RawBlocks min/max and the actual RawBlocks in the database
      saved_raw_block_numbers = RawBlock.pluck(:block_number).sort.uniq
      all_raw_block_numbers   = (start..finish).to_a
      block_numbers_to_fetch  = all_raw_block_numbers - saved_raw_block_numbers

      # Go through all of those block_numbers_to_fetch
      loop do
        # Get current block_number from the front of block_numbers_to_fetch array
        block_number = block_numbers_to_fetch.shift
        break if block_number.blank?

        # Fetch the RawBlock from the blockchain
        begin
          BlockImporterService.get_and_save_raw_block block_number
        rescue Timeout::Error
          puts "!!! Network request timed out. Adding to range to try again. block_number: #{block_number}"
          block_numbers_to_fetch.unshift block_number
          next
        end

        # Check for in sync block RawBlocks between
        # the last in sync RawBlock block_number and the current block_number
        start_again  = synced_block_number.content.to_i
        finish_again = block_number

        (start_again..finish_again).each do |block_number_again|
          # Double check that it’s in the database
          raw_block = RawBlock.find_by block_number: block_number_again

          # If it is, update the setting for in sync RawBlock block_number
          if raw_block.present?
            synced_block_number.update content: raw_block.block_number
          else
            # If not, add that block_number to the front of the block_numbers_to_fetch array to try fetching it again
            puts "!!! RawBlock missing. Adding to range to try again. block_number: #{block_number_again}"
            block_numbers_to_fetch.unshift block_number_again
          end
        end

        # Once block_numbers_to_fetch is empty [], quit!
        break if block_number.blank?
      end

      synced_block_number = Setting.find_by(name: 'raw_blocks_synced_at_block_number').content.to_i
      puts "FINISHED! Current in sync RawBlock: #{synced_block_number}"
    end
  end
end
