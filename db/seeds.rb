require 'concurrent'

# TEMP: for testing time only
RawBlock.destroy_all

# Setup in your .env file at the root of this Rails apps
ETHEREUM_NODE_HOST         = ENV['ETHEREUM_NODE_HOST']         || 'mainnet.infura.io'.freeze
ETHEREUM_NODE_PORT         = ENV['ETHEREUM_NODE_PORT']         || 443
ETHEREUM_NODE_OPEN_TIMEOUT = ENV['ETHEREUM_NODE_OPEN_TIMEOUT'] || 20
ETHEREUM_NODE_READ_TIMEOUT = ENV['ETHEREUM_NODE_READ_TIMEOUT'] || 140
ETHEREUM_NODE_USE_SSL      = ENV['ETHEREUM_NODE_USE_SSL']      || true
ETHEREUM_NODE_RPC_PATH     = ENV['ETHEREUM_NODE_RPC_PATH']     || '/'.freeze

# README:
# If you’re using Infura.io for your host, you’ll need to get an API key from their website.
# Your Infura API key then needs to go into your .env file with a leading slash. For example:
#     ETHEREUM_NODE_RPC_PATH = /1e8cfBC369ADDc93d135

# Connect to the Ethereum node via Web3 / RPC
web3 = Web3::Eth::Rpc.new host: ETHEREUM_NODE_HOST,
                          port: ETHEREUM_NODE_PORT,
                          connect_options: {
                            open_timeout: ETHEREUM_NODE_OPEN_TIMEOUT,
                            read_timeout: ETHEREUM_NODE_READ_TIMEOUT,
                            use_ssl:  ETHEREUM_NODE_USE_SSL,
                            rpc_path: ETHEREUM_NODE_RPC_PATH
                          }

# Get the latest block’s number
latest_block_number = web3.eth.blockNumber

# Get the latest RawBlock from the database
latest_raw_block        = RawBlock.order(block_number: :desc).limit(1).first
latest_raw_block_number = latest_raw_block&.block_number || 0

# Exit if the database is synced up with the blockchain
if latest_raw_block_number >= latest_block_number
  puts "RawBlocks synced with Ethereum blockchain!"
  exit 0
end

# Setup the number of the next block to import
# Fallback to 0 if there are no RawBlocks yet
next_block_number = latest_raw_block.blank? ? 0 : (latest_raw_block_number + 1)

# Work through the blockchain in groups of 1000 blocks at a time
(next_block_number..latest_block_number).each_slice(100) do |slice|
  # Create all of the promises of work to do: get a block, save it to the database
  promises = []

  slice.each do |block_number|
    promises << Concurrent::Promise.execute do
      # Get the next block from the Ethereum node
      block = web3.eth.getBlockByNumber block_number

      ActiveRecord::Base.connection_pool.with_connection do
        # Save the block to the raw_blocks table in the database
        raw_block = RawBlock.create! block_number: block.block_number, content: block.raw_data
        puts "Saved block: #{raw_block.block_number}"
      end
    end
  end

  # Do the work in all of the promises: get a block, save it to the database
  promises.map { |promise| puts promise.value; promise.value }
end

puts
puts "Latest block on blockchain (at start of sync): #{latest_block_number}"
puts "RawBlocks now in the database:                 #{RawBlock.count}"
puts
