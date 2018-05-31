namespace :ethio do
  namespace :blockchain do
    desc 'Sync blocks from the Ethereum blockchain into the raw_blocks database table'
    task sync: :environment do
      puts 'Syncing blockchain…'
      puts
      puts "RawBlocks now in the database: #{BlockImporterService.raw_blocks_count}"
      puts "Latest RawBlock block_number:  #{BlockImporterService.latest_raw_block_number}"
      puts

      BlockImporterService.save_in_sync_block_number

      # Set the lowest block number to be fetched
      last_in_sync_block_number  = Setting.find_by(name: 'raw_blocks_previous_synced_at_block_number').content
      lowest_block_number_needed = last_in_sync_block_number.to_i

      BlockImporterService.get_blocks_from_blockchain starting_block_number: lowest_block_number_needed

      puts
      puts "When in sync, latest block number is -1 of RawBlocks count"
      puts "RawBlocks now in the database:                 #{BlockImporterService.raw_blocks_count}"
      puts "Latest block on blockchain (at start of sync): #{BlockImporterService.latest_block_number}"
      puts
    end
  end
end
