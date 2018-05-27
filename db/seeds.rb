require 'concurrent'

HTTP_THREAD_COUNT = (ENV['HTTP_THREAD_COUNT'].to_i || 100).freeze

# Add a setting to save the block_number of the last known place
# where the database was in sync with the blockchain
Setting.find_or_create_by name: 'raw_blocks_previous_synced_at_block_number' do |setting|
  setting.content     = 0
  setting.data_type   = 'Integer'
  setting.description = 'When the database has the same number of RawBlocks as the largest
                         `block_number` (minus one) in the `raw_blocks` table, then the table
                         is in sync with the blockchain. At least, up to that `block_number`.
                         When that moment happens, this `Setting` gets updated to that that
                         `block_number`. That way, future jobs will know to never search below
                         that `block_number` for missing blocks when trying to sync with the
                         blockchain again.'
end


puts
puts "RawBlocks now in the database: #{BlockImporterService.raw_blocks_count}"
puts "Latest RawBlock block_number:  #{BlockImporterService.latest_raw_block_number}"
puts

BlockImporterService.save_in_sync_block_number


# Set the lowest block number to be fetched
last_in_sync_block_number  = Setting.find_by(name: 'raw_blocks_previous_synced_at_block_number').content
lowest_block_number_needed = last_in_sync_block_number.to_i + 1

# Work through the blockchain in groups of blocks at a time
lowest_block_number_needed.upto(BlockImporterService.latest_block_number).each_slice(HTTP_THREAD_COUNT) do |block_numbers|
  # Create all of the promisess of work to do: get a block, save it to the database
  promises = []

  block_numbers.each do |block_number|
    promise = Concurrent::Promise.new(executor: BlockImporterService.thread_pool_executor) do
      puts "==> Fetching block from chain: #{block_number}"
      block = BlockImporterService.web3.eth.getBlockByNumber block_number

      ActiveRecord::Base.connection_pool.with_connection do
        # Save the block to the raw_blocks table in the database
        raw_block = RawBlock.create block_number: block.block_number, content: block.raw_data.to_json
        puts "+++ Saved block: #{raw_block.block_number}"
      end
    end

    promises << promise.execute
  end

  # Do the work in all of the promises: get a block, save it to the database
  promises.map { |p| p.value }

  puts
  puts "RawBlocks now in the database: #{BlockImporterService.raw_blocks_count}"

  BlockImporterService.save_in_sync_block_number
end


puts
puts "When in sync, latest block number is -1 of RawBlocks count"
puts "RawBlocks now in the database:                 #{BlockImporterService.raw_blocks_count}"
puts "Latest block on blockchain (at start of sync): #{BlockImporterService.latest_block_number}"
puts
