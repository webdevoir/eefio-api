class AddIndexToRawBlocksOnBlockExtractedAt < ActiveRecord::Migration[5.2]
  def change
    add_index :raw_blocks, :block_extracted_at
  end
end
