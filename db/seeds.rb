require 'concurrent'

# TODO: move out seeds to a better place
def save_in_sync_block_number
  # Get the count of RawBlocks from the database
  raw_blocks_count = RawBlock.count || 0

  # Get the latest RawBlock’s block_number in the database
  latest_raw_block_number = RawBlock.order(block_number: :desc).limit(1).first.block_number || 0

  # Update last synced block number setting.
  # The +1 is because the first block is 0.
  # Eg, If latest_raw_block_number is 2. The database will have be RawBlocks: 0, 1, 2.
  if raw_blocks_count == (latest_raw_block_number + 1)
    update_raw_blocks_previous_synced_at_block_number_setting! block_number: latest_raw_block_number
  end
end

# TODO: move out seeds to a better place
def update_raw_blocks_previous_synced_at_block_number_setting! block_number:
  setting = Setting.find_by name: 'raw_blocks_previous_synced_at_block_number'
  return if setting.content.to_i == block_number

  puts
  puts "Updating Setting"
  puts "==> raw_blocks_previous_synced_at_block_number: #{block_number}"
  puts

  setting.update content: block_number
end

# README:
# If you’re using Infura.io for your host, you’ll need to get an API key from their website.
# Your Infura API key then needs to go into your .env file with a leading slash. For example:
#     ETHEREUM_NODE_RPC_PATH = /1e8cfBC369ADDc93d135
# Setup in your .env file at the root of this Rails apps
ETHEREUM_NODE_HOST         = ENV['ETHEREUM_NODE_HOST']         || 'mainnet.infura.io'.freeze
ETHEREUM_NODE_PORT         = ENV['ETHEREUM_NODE_PORT']         || 443
ETHEREUM_NODE_OPEN_TIMEOUT = ENV['ETHEREUM_NODE_OPEN_TIMEOUT'] || 20
ETHEREUM_NODE_READ_TIMEOUT = ENV['ETHEREUM_NODE_READ_TIMEOUT'] || 140
ETHEREUM_NODE_USE_SSL      = ENV['ETHEREUM_NODE_USE_SSL']      || true
ETHEREUM_NODE_RPC_PATH     = ENV['ETHEREUM_NODE_RPC_PATH']     || '/'.freeze
HTTP_THREAD_COUNT          = ENV['HTTP_THREAD_COUNT'].to_i     || 100


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


# Connect to the Ethereum node via Web3 / RPC
web3 = Web3::Eth::Rpc.new host: ETHEREUM_NODE_HOST,
                          port: ETHEREUM_NODE_PORT,
                          connect_options: {
                            open_timeout: ETHEREUM_NODE_OPEN_TIMEOUT,
                            read_timeout: ETHEREUM_NODE_READ_TIMEOUT,
                            use_ssl:  ETHEREUM_NODE_USE_SSL,
                            rpc_path: ETHEREUM_NODE_RPC_PATH
                          }

# Get the latest RawBlock’s block_number in the database
latest_raw_block_number = RawBlock.order(block_number: :desc).limit(1).first.block_number || 0

# Get the count of RawBlocks from the database
raw_blocks_count = RawBlock.count || 0

puts
puts "Latest RawBlock block_number: #{latest_raw_block_number}"
puts "Current RawBlocks count:      #{raw_blocks_count}"
puts

save_in_sync_block_number


# Set the lowest block number to be fetched
last_in_sync_block_number  = Setting.find_by(name: 'raw_blocks_previous_synced_at_block_number').content
lowest_block_number_needed = last_in_sync_block_number.to_i + 1

# Get latest block number from the blockchain
latest_block_number = web3.eth.blockNumber


# Use our own thread pool
pool = Concurrent::ThreadPoolExecutor.new(
         min_threads:     [2, Concurrent.processor_count].max,
         max_threads:     100,
         auto_terminate:  true,
         idletime:        60,    # 1 minute
         max_queue:       0,     # unlimited
         fallback_policy: :abort # shouldn't matter with '0 max queue'
       )


# Work through the blockchain in groups of blocks at a time
latest_block_number.downto(lowest_block_number_needed).each_slice(HTTP_THREAD_COUNT) do |block_numbers|
  # Create all of the promisess of work to do: get a block, save it to the database
  promises = []

  block_numbers.each do |block_number|
    promise = Concurrent::Promise.new(executor: pool) do
      puts "==> Fetching block from chain: #{block_number}"
      block = web3.eth.getBlockByNumber block_number

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
  puts "RawBlocks now in the database: #{RawBlock.count}"

  save_in_sync_block_number
end


puts
puts "Latest block on blockchain (at start of sync): #{latest_block_number}"
puts "RawBlocks now in the database:                 #{RawBlock.count}"
puts
