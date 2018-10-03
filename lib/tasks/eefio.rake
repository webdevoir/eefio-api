namespace :eefio do
  desc 'Check the current stats of the database and blockchain sync'
  task stats: :environment do
    latest_blockchain_block_number = Ethereum.fetch_latest_block_number
    latest_raw_block_number        = Setting.raw_blocks_synced_at_block_number.content.to_i
    latest_extracted_block_number  = Setting.blocks_extracted_up_to_block_number.content.to_i

    # raw_blocks_with_unextracted_transactions = RawBlock.where(transactions_extracted_at: nil).count

    length = [latest_blockchain_block_number.to_s.length,
              latest_raw_block_number.to_s.length,
              latest_extracted_block_number.to_s.length].max

    raw_blocks_ethereum_offset               = (latest_blockchain_block_number - latest_raw_block_number).abs
    imported_extracted_offset                = (latest_extracted_block_number  - latest_raw_block_number).abs

    puts '-' * 50
    puts
    puts Time.current
    puts
    puts "#{latest_blockchain_block_number.to_s.rjust length, ' '} : Ethereum  block number"
    puts "#{latest_raw_block_number.to_s.rjust        length, ' '} : Imported  block number"
    puts "#{latest_extracted_block_number.to_s.rjust  length, ' '} : Extracted block number"
    puts
    puts "#{raw_blocks_ethereum_offset.to_s.rjust length,  ' '} : RawBlocks / Ethereum  offset"
    puts "#{imported_extracted_offset.to_s.rjust  length,  ' '} : RawBlocks / Extracted offset Blocks"
    # puts "#{raw_blocks_with_unextracted_transactions.to_s.rjust  length,  ' '} : RawBlocks / Extracted offset Transactions"
    puts
    puts '-' * 50
  end
end
