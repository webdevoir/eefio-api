class Setting < ApplicationRecord
  class << self
    def raw_blocks_synced_at_block_number
      find_by name: 'raw_blocks_synced_at_block_number'
    end
  end
end
