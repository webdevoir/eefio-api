class RawBlock < ApplicationRecord
  validates :block_number, presence: true # , uniqueness: true
  after_create :extract_block

  class << self
    def last_in_sync_block_number
      Setting.find_by(name: 'raw_blocks_previous_synced_at_block_number').content.to_i
    end

    def latest_block_number
      # Get the latest RawBlock’s block_number in the database
      order(block_number: :desc).limit(1).first&.block_number || 0
    end
  end

  def extract_block
    puts "==> Extracting Block from RawBlock: #{self.id}…"
    BlockExtractorService.extract_block_from raw_block: self
    puts "==> Extracting Block from RawBlock: #{self.id}… done."
  end
end
