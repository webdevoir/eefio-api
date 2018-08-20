class BlockImporterService
  # README:
  # If you’re using Infura.io for your host, you’ll need to get an API key from their website.
  # Your Infura API key then needs to go into your .env file with a leading slash. For example:
  #     ETHEREUM_NODE_RPC_PATH = /1e8cfBC369ADDc93d135
  # Setup in your .env file at the root of this Rails apps
  ETHEREUM_NODE_HOST          = (ENV['ETHEREUM_NODE_HOST']          || 'mainnet.infura.io').freeze
  ETHEREUM_NODE_PORT          = (ENV['ETHEREUM_NODE_PORT']          || 443).freeze
  ETHEREUM_NODE_OPEN_TIMEOUT  = (ENV['ETHEREUM_NODE_OPEN_TIMEOUT']  || 20).freeze
  ETHEREUM_NODE_READ_TIMEOUT  = (ENV['ETHEREUM_NODE_READ_TIMEOUT']  || 140).freeze
  ETHEREUM_NODE_USE_SSL       = (ENV['ETHEREUM_NODE_USE_SSL']       || true).freeze
  ETHEREUM_NODE_RPC_PATH      = (ENV['ETHEREUM_NODE_RPC_PATH']      || '/').freeze
  EEFIO_JOB_QUEUE_MAX_SIZE    = (ENV['EEFIO_JOB_QUEUE_MAX_SIZE']    || 10000).to_i.freeze
  EEFIO_SECONDS_FOR_NEW_BLOCK = (ENV['EEFIO_SECONDS_FOR_NEW_BLOCK'] || 12).to_i.freeze

  class << self
    def get_and_save_raw_block block_number
      # raw_block = RawBlock.find_by block_number: block_number

      # if raw_block.present?
      #   puts "___ RawBlock already exists: #{block_number}"
      # else
        block = get_block_from_blockchain block_number: block_number
        create_raw_block_from block: block
      # end
    end

    def get_blocks_from_blockchain starting_block_number:, ending_block_number: nil
      # Don’t try to fetch blocks that don’t exist on the blockchain yet
      if ending_block_number.blank?
        ending_block_number = [
          (starting_block_number + EEFIO_JOB_QUEUE_MAX_SIZE), latest_block_number
        ].min
      end

      # Work through the blockchain in groups of blocks at a time
      starting_block_number.upto(ending_block_number).each_slice(EEFIO_JOB_QUEUE_MAX_SIZE) do |block_numbers|
        block_numbers.each do |block_number|
          puts "==> Enqueuing ImportRawBlockFromBlockchainJob for block number: #{block_number}"
          ImportRawBlockFromBlockchainJob.perform_later block_number: block_number
        end
      end

      starting_block_number = ending_block_number + 1
      ending_block_number   = starting_block_number + EEFIO_JOB_QUEUE_MAX_SIZE

      sleep_if_necessary

      enqueue_next_batch starting_block_number: starting_block_number,
                         ending_block_number:   ending_block_number
    end

    def sleep_if_necessary
      # # When synced up with the blockchain, wait for a new block to be added before trying again
      # if latest_raw_block_number == get_latest_block_number
      #   puts "!!! Sleeping for #{EEFIO_SECONDS_FOR_NEW_BLOCK} seconds"
      #   sleep EEFIO_SECONDS_FOR_NEW_BLOCK
      # end

      sleep EEFIO_SECONDS_FOR_NEW_BLOCK
    end

    def enqueue_next_batch starting_block_number:, ending_block_number:
      EnqueueBlockchainSyncJobsJob.perform_later starting_block_number: starting_block_number,
                                                 ending_block_number:   ending_block_number
    end

    def get_block_from_blockchain block_number:
      puts "==> Fetching block from chain: #{block_number}"
      web3.eth.getBlockByNumber block_number
    end

    def create_raw_block_from block:
      # Save the block to the raw_blocks table in the database
      raw_block = RawBlock.create block_number: block.block_number, content: block.raw_data.to_json
      puts "+++ Saved block: #{raw_block.block_number}" if raw_block.created_at.present?
    end

    def latest_block_number
      # Get latest block number from the blockchain
      @latest_block_number ||= get_latest_block_number
    end

    def get_latest_block_number
      web3.eth.blockNumber
    end

    def latest_raw_block_number
      # Get the latest RawBlock’s block_number in the database
      RawBlock.order(block_number: :desc).limit(1).first&.block_number || 0
    end

    def raw_blocks_count
      # Get the count of RawBlocks from the database
      RawBlock.count || 0
    end

    # def save_in_sync_block_number
    #   block_number = latest_raw_block_number
    #   puts
    #   puts "Block Number: #{block_number}"
    #   puts "Raw Blocks Count: #{raw_blocks_count}"
    #   puts
    #
    #   # Update last synced block number setting.
    #   # The +1 is because the first block is 0.
    #   # Eg, If latest_raw_block_number is 2. The database will have be RawBlocks: 0, 1, 2.
    #   if raw_blocks_count == (block_number + 1)
    #     puts "Saving last synced block number setting…"
    #     update_raw_blocks_previous_synced_at_block_number_setting! block_number: block_number
    #   else
    #     # There are some gaps in the RawBlocks table
    #     # Figure out which ones are missing
    #     # Go get them and save them
    #     fetch_missing_raw_blocks
    #   end
    # end

    def update_raw_blocks_previous_synced_at_block_number_setting! block_number:
      setting = Setting.find_by name: 'raw_blocks_previous_synced_at_block_number'
      return if setting.content.to_i == block_number

      puts
      puts "Updating Setting"
      puts "==> raw_blocks_previous_synced_at_block_number: #{block_number}"
      puts

      setting.update content: block_number
    end

    # def missing_raw_blocks
    #   existing_raw_block_numbers_in_the_db = RawBlock.pluck(:block_number).sort.uniq
    #   all_raw_block_numbers                = (RawBlock.last_in_sync_block_number..RawBlock.last.block_number).to_a
    #
    #   (all_raw_block_numbers - existing_raw_block_numbers_in_the_db).compact
    # end

    # def fetch_missing_raw_blocks
    #   if missing_raw_blocks.present?
    #     puts "!!! Missing blocks:"
    #     puts "  #{missing_raw_blocks}"
    #   end
    #
    #   missing_raw_blocks.each do |block_number|
    #     puts "!!! Raw Block is missing: #{block_number}"
    #     get_and_save_raw_block block_number
    #   end
    #
    #   # Try to save in sync block number again
    #   # This will loop back and forth until all the missing blocks are fetched
    #   save_in_sync_block_number
    # end

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
