class AddBlockExtractedAtToRawBlocks < ActiveRecord::Migration[5.2]
  def change
    add_column :raw_blocks, :block_extracted_at, :datetime
  end
end
