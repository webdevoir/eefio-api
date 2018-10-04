class AddIndexOnAddressBlocks < ActiveRecord::Migration[5.2]
  def change
    add_index :blocks, :address
  end
end
