namespace :eefio do
  namespace :blockchain do
    desc 'Sync blocks from the Ethereum blockchain into the raw_blocks database table'
    task sync: :environment do
      latest_raw_block_number = RawBlock.latest_block_number
      in_sync_block_number    = Setting.raw_blocks_synced_at_block_number.content.to_i

      puts '___ Syncing blockchain…'
      puts
      puts "___ Latest RawBlock block_number:       #{latest_raw_block_number}"
      puts "___ Last in sync RawBlock block_number: #{in_sync_block_number}"
      puts

      starting_block_number = latest_raw_block_number
      ending_block_number   = Ethereum.get_latest_block_number

      puts "___ Getting RawBlocks for block numbers: #{starting_block_number} - #{ending_block_number}"
      puts

      BlockImporterService.get_blocks_from_blockchain starting_block_number: starting_block_number,
                                                      ending_block_number:   ending_block_number
    end
  end
end
