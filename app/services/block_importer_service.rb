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
    HTTP_THREAD_COUNT          = (ENV['HTTP_THREAD_COUNT'].to_i     || 100).freeze

    def get_and_save_raw_block block_number
      block = get_block_from_blockchain block_number: block_number
      create_raw_block_from block: block
    end

    def get_blocks_from_blockchain starting_block_number:, ending_block_number: nil
      ending_block_number = latest_block_number if ending_block_number.blank?

      # Work through the blockchain in groups of blocks at a time
      starting_block_number.upto(ending_block_number).each_slice(HTTP_THREAD_COUNT) do |block_numbers|
        if HTTP_THREAD_COUNT == 1
          # Synchronous
          block_numbers.each do |block_number|
            get_and_save_raw_block block_number
          end
        else
          # Asynchronous
          # Create all of the promisess of work to do: get a block, save it to the database
          promises = []
          promises = block_numbers.map { |block_number| promise_to_create_raw_block block_number }

          # Do the work in all of the promises: get a block, save it to the database
          promises.map(&:value)
        end

        puts
        puts "RawBlocks now in the database: #{raw_blocks_count}"

        save_in_sync_block_number
      end
    end

    def get_block_from_blockchain block_number:
      puts "==> Fetching block from chain: #{block_number}"
      web3.eth.getBlockByNumber block_number
    end

    def create_raw_block_from block:
      ActiveRecord::Base.connection_pool.with_connection do
        # Save the block to the raw_blocks table in the database
        raw_block = RawBlock.create block_number: block.block_number, content: block.raw_data.to_json
        puts "+++ Saved block: #{raw_block.block_number}"
      end
    end

    def promise_to_create_raw_block block_number
      promise = Concurrent::Promise.new(executor: thread_pool_executor) do
        get_and_save_raw_block block_number
      end

      promise.execute
    end

    def latest_block_number
      # Get latest block number from the blockchain
      @latest_block_number ||= web3.eth.blockNumber
    end

    def latest_raw_block_number
      # Get the latest RawBlock’s block_number in the database
      RawBlock.order(block_number: :desc).limit(1).first&.block_number || 0
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

    def thread_pool_executor
      # Use our own thread pool
      @thread_pool_executor = Concurrent::ThreadPoolExecutor.new(
                                min_threads:     [2, Concurrent.processor_count].max,
                                max_threads:     100,
                                auto_terminate:  true,
                                idletime:        60,    # 1 minute
                                max_queue:       0,     # unlimited
                                fallback_policy: :abort # shouldn't matter with '0 max queue'
                              )
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

    def web3
      # Connect to the Ethereum node via Web3 / RPC
      @web3 ||= Web3::Eth::Rpc.new host: ETHEREUM_NODE_HOST,
                                   port: ETHEREUM_NODE_PORT,
                                   connect_options: {
                                     open_timeout: ETHEREUM_NODE_OPEN_TIMEOUT,
                                     read_timeout: ETHEREUM_NODE_READ_TIMEOUT,
                                     use_ssl:  ETHEREUM_NODE_USE_SSL,
                                     rpc_path: ETHEREUM_NODE_RPC_PATH
                                   }
    end
  end
end
