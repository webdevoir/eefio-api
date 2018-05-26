class BlockImporter
  class << self

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
