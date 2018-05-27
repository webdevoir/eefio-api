class CreateBlocks < ActiveRecord::Migration[5.2]
  def change
    create_table :blocks do |t|
      t.text :address
      t.bigint :block_number, limit: 8
      t.string :block_number_in_hex
      t.bigint :difficulty, limit: 8
      t.string :difficulty_in_hex
      t.text :extra_data
      t.bigint :gas_limit, limit: 8
      t.string :gas_limit_in_hex
      t.bigint :gas_used, limit: 8
      t.string :gas_used_in_hex
      t.text :logs_bloom
      t.text :miner_address
      t.text :mix_hash
      t.bigint :nonce, limit: 8
      t.string :nonce_in_hex
      t.text :parent_block_address
      t.datetime :published_at
      t.string :published_at_in_hex
      t.text :receipts_root
      t.text :sha3_uncles
      t.bigint :size_in_bytes, limit: 8
      t.string :size_in_hex
      t.text :state_root
      t.bigint :total_difficulty, limit: 8
      t.string :total_difficulty_in_hex
      t.text :transactions_root
      t.string :uncles

      t.timestamps
    end
  end
end
