class AddIndexToBlocks < ActiveRecord::Migration[5.2]
  def change
    add_index :blocks, :block_number
  end
end
