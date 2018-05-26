class BlockImporterService
  class << self

    # README:
    # If you’re using Infura.io for your host, you’ll need to get an API key from their website.
    # Your Infura API key then needs to go into your .env file with a leading slash. For example:
    #     ETHEREUM_NODE_RPC_PATH = /1e8cfBC369ADDc93d135
    # Setup in your .env file at the root of this Rails apps
    ETHEREUM_NODE_HOST         = (ENV['ETHEREUM_NODE_HOST']         || 'mainnet.infura.io').freeze
    ETHEREUM_NODE_PORT         = (ENV['ETHEREUM_NODE_PORT']         || 443).freeze
    ETHEREUM_NODE_OPEN_TIMEOUT = (ENV['ETHEREUM_NODE_OPEN_TIMEOUT'] || 20).freeze
    ETHEREUM_NODE_READ_TIMEOUT = (ENV['ETHEREUM_NODE_READ_TIMEOUT'] || 140).freeze
    ETHEREUM_NODE_USE_SSL      = (ENV['ETHEREUM_NODE_USE_SSL']      || true).freeze
    ETHEREUM_NODE_RPC_PATH     = (ENV['ETHEREUM_NODE_RPC_PATH']     || '/').freeze

    # Connect to the Ethereum node via Web3 / RPC
    def web3
      Web3::Eth::Rpc.new host: ETHEREUM_NODE_HOST,
                         port: ETHEREUM_NODE_PORT,
                         connect_options: {
                           open_timeout: ETHEREUM_NODE_OPEN_TIMEOUT,
                           read_timeout: ETHEREUM_NODE_READ_TIMEOUT,
                           use_ssl:  ETHEREUM_NODE_USE_SSL,
                           rpc_path: ETHEREUM_NODE_RPC_PATH
                         }
    end

    def latest_block_number
      # Get latest block number from the blockchain
      @latest_block_number ||= BlockImporterService.web3.eth.blockNumber
    end

    def latest_raw_block_number
      # Get the latest RawBlock’s block_number in the database
      RawBlock.order(block_number: :desc).limit(1).first.block_number || 0
    end

    def raw_blocks_count
      # Get the count of RawBlocks from the database
      RawBlock.count || 0
    end

    def save_in_sync_block_number
      # Update last synced block number setting.
      # The +1 is because the first block is 0.
      # Eg, If latest_raw_block_number is 2. The database will have be RawBlocks: 0, 1, 2.
      if raw_blocks_count == (latest_raw_block_number + 1)
        update_raw_blocks_previous_synced_at_block_number_setting! block_number: latest_raw_block_number
      end
    end

    def update_raw_blocks_previous_synced_at_block_number_setting! block_number:
      setting = Setting.find_by name: 'raw_blocks_previous_synced_at_block_number'
      return if setting.content.to_i == block_number

      puts
      puts "Updating Setting"
      puts "==> raw_blocks_previous_synced_at_block_number: #{block_number}"
      puts

      setting.update content: block_number
    end

  end
end
