class RawBlock < ApplicationRecord
  validates :block_number, presence: true, uniqueness: true

  class << self
    def last_in_sync_block_number
      Setting.find_by(name: 'raw_blocks_previous_synced_at_block_number').content.to_i
    end
  end
end
