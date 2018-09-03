class Setting < ApplicationRecord
  class << self
    def raw_blocks_synced_at_block_number
      find_by name: 'raw_blocks_synced_at_block_number'
    end

    def blocks_extracted_up_to_block_number
      find_by name: 'blocks_extracted_up_to_block_number'
    end

    def transactions_extracted_up_to_block_number
      find_by name: 'transactions_extracted_up_to_block_number'
    end
  end
end
