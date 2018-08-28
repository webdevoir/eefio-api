namespace :eefio do
  namespace :raw_blocks do
    desc 'Starts at the start and finds missing raw_blocks in the database, fetches them from blockchain'
    task fetch_missing: :environment do
      # Get in sync RawBlock setting, and build range to check within
      start  = Setting.raw_blocks_synced_at_block_number.content.to_i
      finish = RawBlock.latest_block_number

      # Fallback to something for development and testing
      finish = 20 if Rails.env.development? && finish.zero?

      # Find the missing RawBlocks by finding the difference between
      # the range of RawBlocks min/max and the actual RawBlocks in the database
      saved_block_numbers       = RawBlock.pluck(:block_number).sort.uniq
      saved_block_numbers_range = (start..finish).to_a
      block_numbers_to_fetch    = saved_block_numbers_range - saved_block_numbers

      # Go through all of those block_numbers_to_fetch
      BlockImporterService.fetch_blocks_from_blockchain block_numbers: block_numbers_to_fetch

      synced_block_number = Setting.raw_blocks_synced_at_block_number.content.to_i
      puts "___ FINISHED! Current in sync RawBlock: #{synced_block_number}"
    end
  end
end
