namespace :eefio do
  desc 'Check the current stats of the database and blockchain sync'
  task stats: :environment do
    latest_blockchain_block_number = Ethereum.fetch_latest_block_number
    latest_raw_block_number        = Setting.raw_blocks_synced_at_block_number.content.to_i
    latest_extracted_block_number  = Setting.blocks_extracted_up_to_block_number.content.to_i

    length = [latest_blockchain_block_number.to_s.length,
              latest_raw_block_number.to_s.length,
              latest_extracted_block_number.to_s.length].max

    raw_blocks_ethereum_offset = (latest_blockchain_block_number - latest_raw_block_number).abs
    imported_extracted_offset  = (latest_extracted_block_number  - latest_raw_block_number).abs

    puts '-' * 50
    puts
    puts Time.current
    puts
    puts "Ethereum  block number: #{latest_blockchain_block_number.to_s.rjust length, ' '}"
    puts "Imported  block number: #{latest_raw_block_number.to_s.rjust        length, ' '}"
    puts "Extracted block number: #{latest_extracted_block_number.to_s.rjust  length, ' '}"
    puts
    puts "RawBlocks / Ethereum  offset: #{raw_blocks_ethereum_offset.to_s.rjust length,  ' '}"
    puts "Imported  / Extracted offset: #{imported_extracted_offset.to_s.rjust  length,  ' '}"
    puts
    puts '-' * 50
  end
end
