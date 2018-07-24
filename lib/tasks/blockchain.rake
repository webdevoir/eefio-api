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

      eefio_job_queue_max_size = (ENV['EEFIO_JOB_QUEUE_MAX_SIZE'] || 10000).to_i.freeze
      starting_block_number    = latest_raw_block_number

      ending_block_number      = [
        (starting_block_number + eefio_job_queue_max_size),
        BlockImporterService.latest_block_number
      ].min

      puts "==> Creating Jobs for block numbers: #{starting_block_number} - #{ending_block_number}"
      puts

      BlockImporterService.get_blocks_from_blockchain starting_block_number: starting_block_number,
                                                      ending_block_number:   ending_block_number
    end
  end
end
