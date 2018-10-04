class AddIndexToRawBlocksOnTransactionsExtractedAt < ActiveRecord::Migration[5.2]
  def change
    add_index :raw_blocks, :transactions_extracted_at
  end
end
