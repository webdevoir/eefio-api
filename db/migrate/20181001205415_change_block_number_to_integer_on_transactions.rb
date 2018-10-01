class ChangeBlockNumberToIntegerOnTransactions < ActiveRecord::Migration[5.2]
  def up
    change_column :transactions, :block_number, :integer
  end

  def down
    change_column :transactions, :block_number, :decimal
  end
end
