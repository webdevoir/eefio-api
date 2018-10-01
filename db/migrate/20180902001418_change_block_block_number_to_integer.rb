class ChangeBlockBlockNumberToInteger < ActiveRecord::Migration[5.2]
  def up
    change_column :blocks, :block_number, :integer
  end

  def down
    change_column :blocks, :block_number, :decimal
  end
end
