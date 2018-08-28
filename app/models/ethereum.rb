class Ethereum
  # README:
  # If you’re using Infura.io for your host, you’ll need to get an API key from their website.
  # Your Infura API key then needs to go into your .env file with a leading slash. For example:
  #     ETHEREUM_NODE_RPC_PATH = /1e8cfBC369ADDc93d135
  #
  # Setup in your .env file at the root of this Rails app
  ETHEREUM_NODE_HOST         = (ENV['ETHEREUM_NODE_HOST']         || 'mainnet.infura.io').freeze
  ETHEREUM_NODE_PORT         = (ENV['ETHEREUM_NODE_PORT']         || 443).freeze
  ETHEREUM_NODE_OPEN_TIMEOUT = (ENV['ETHEREUM_NODE_OPEN_TIMEOUT'] || 20).freeze
  ETHEREUM_NODE_READ_TIMEOUT = (ENV['ETHEREUM_NODE_READ_TIMEOUT'] || 140).freeze
  ETHEREUM_NODE_USE_SSL      = (ENV['ETHEREUM_NODE_USE_SSL']      || true).freeze
  ETHEREUM_NODE_RPC_PATH     = (ENV['ETHEREUM_NODE_RPC_PATH']     || '/').freeze

  class << self
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

    def fetch_latest_block_number
      web3.eth.blockNumber
    end

    def get_block block_number:
      puts
      puts "==> Fetching block from chain: #{block_number}"
      web3.eth.getBlockByNumber block_number
    end
  end
end
