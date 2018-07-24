namespace :eefio do
  namespace :blockchain do
    desc 'Sync blocks from the Ethereum blockchain into the raw_blocks database table'
    task sync: :environment do
      latest_raw_block_number = BlockImporterService.latest_raw_block_number

      puts '___ Syncing blockchain…'
      puts
      puts "___ RawBlocks now in the database: #{BlockImporterService.raw_blocks_count}"
      puts "___ Latest RawBlock block_number:  #{latest_raw_block_number}"
      puts

      starting_block_number = latest_raw_block_number
      ending_block_number   = BlockImporterService::EEFIO_JOB_QUEUE_MAX_SIZE

      puts "==> Creating Jobs for block numbers: #{starting_block_number} - #{ending_block_number}"
      puts

      BlockImporterService.get_blocks_from_blockchain starting_block_number: starting_block_number
    end
  end
end
