namespace :eefio do
  namespace :raw_blocks do
    desc 'Starts at the start and finds missing raw_blocks in the database, fetches them from blockchain'
    task fetch_missing: :environment do

      # Get in sync RawBlock setting
      synced_block_number = Setting.find_by name: 'raw_blocks_previous_synced_at_block_number'

      # Build range to check within
      start  = synced_block_number.content.to_i
      finish = RawBlock.latest_block_number

      # Fallback to something for development and testing
      finish = 20 if Rails.env.development? && finish.zero?

      # Find the missing RawBlocks by finding the difference between
      # the range of RawBlocks min/max and the actual RawBlocks in the database
      saved_raw_block_numbers = RawBlock.pluck(:block_number).uniq.sort
      all_raw_block_numbers   = (start..finish).to_a
      missing_block_numbers   = all_raw_block_numbers - saved_raw_block_numbers

      # Go through all of those missing_block_numbers
      loop do
        # Get current block_number from the front of missing_block_numbers array
        block_number = missing_block_numbers.shift
        break if block_number.blank?

        # Fetch the RawBlock from the blockchain
        puts '*'*80
        p block_number
        puts '*'*80
        BlockImporterService.get_and_save_raw_block block_number

        # Check for in sync block RawBlocks between
        # the last in sync RawBlock block_number and the current block_number
        start_again  = synced_block_number.content.to_i
        finish_again = block_number

        (start_again..finish_again).each do |block_number|
          # Double check that it’s in the database
          raw_block = RawBlock.find_by block_number: block_number

          # If it is, update the setting for in sync RawBlock block_number
          if raw_block.present?
            synced_block_number.update content: raw_block.block_number
            puts "+++ Updated Setting(raw_blocks_previous_synced_at_block_number) to: #{raw_block.block_number}"
          else
            # If not, add that block_number to the front of the missing_block_numbers array to try fetching it again
            puts "!!! RawBlock missing. Adding to range to try again. block_number: #{block_number}"
            missing_block_numbers.unshift block_number
          end
        end

        # Once missing_block_numbers is empty [], quit!
        break if block_number.blank?
      end

      synced_block_number = Setting.find_by(name: 'raw_blocks_previous_synced_at_block_number').content.to_i
      puts "FINISHED! Current in sync RawBlock: #{synced_block_number}"
    end
  end
end