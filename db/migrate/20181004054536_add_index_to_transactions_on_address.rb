class AddIndexToTransactionsOnAddress < ActiveRecord::Migration[5.2]
  def change
    add_index :transactions, :address
  end
end
