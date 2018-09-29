class AddPublishedAtToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :published_at,                               :datetime
    add_column :transactions, :published_at_in_seconds_since_epoch_in_hex, :string
    add_column :transactions, :published_at_in_seconds_since_epoch,        :decimal
  end
end
