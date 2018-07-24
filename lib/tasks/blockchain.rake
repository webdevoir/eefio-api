namespace :eefio do
  namespace :blockchain do
    desc 'Sync blocks from the Ethereum blockchain into the raw_blocks database table'
    task sync: :environment do
      puts 'Syncing blockchain…'
      puts
      puts "RawBlocks now in the database: #{BlockImporterService.raw_blocks_count}"
      puts "Latest RawBlock block_number:  #{BlockImporterService.latest_raw_block_number}"
      puts

      starting_block_number = RawBlock.last_in_sync_block_number
      BlockImporterService.get_blocks_from_blockchain starting_block_number: starting_block_number
    end
  end
end
