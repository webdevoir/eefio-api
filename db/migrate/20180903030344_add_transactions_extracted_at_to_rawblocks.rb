class AddTransactionsExtractedAtToRawblocks < ActiveRecord::Migration[5.2]
  def change
    add_column :raw_blocks, :transactions_extracted_at, :datetime
  end
end