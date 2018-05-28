class CreateBlocks < ActiveRecord::Migration[5.2]
  def change
    create_table :blocks do |t|
      t.text :address, uniq: true
      t.decimal :block_number, uniq: true
      t.string :block_number_in_hex, uniq: true
      t.decimal :difficulty
      t.string :difficulty_in_hex
      t.text :extra_data
      t.decimal :gas_limit
      t.string :gas_limit_in_hex
      t.decimal :gas_used
      t.string :gas_used_in_hex
      t.text :logs_bloom
      t.text :miner_address
      t.text :mix_hash
      t.decimal :nonce
      t.string :nonce_in_hex
      t.text :parent_block_address
      t.datetime :published_at
      t.string :published_at_in_seconds_since_epoch_in_hex
      t.decimal :published_at_in_seconds_since_epoch
      t.text :receipts_root_address
      t.text :sha3_uncles
      t.decimal :size_in_bytes
      t.string :size_in_bytes_in_hex
      t.text :state_root_address
      t.decimal :total_difficulty
      t.string :total_difficulty_in_hex
      t.text :transactions_root_address
      t.string :uncles

      t.timestamps
    end
  end
end
