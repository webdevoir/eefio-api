class CreateTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :transactions do |t|
      t.references :block
      t.string :block_address
      t.decimal :block_number
      t.string :block_number_in_hex
      t.string :address
      t.decimal :nonce
      t.string :nonce_in_hex
      t.string :to
      t.string :from
      t.decimal :gas_provided
      t.decimal :gas_price_in_wei
      t.string :gas_price_in_wei_in_hex
      t.text :input
      t.decimal :eth_sent_in_wei
      t.string :eth_sent_in_wei_in_hex
      t.integer :index_on_block
      t.string :index_on_block_in_hex
      t.integer :v
      t.string :v_in_hex
      t.string :r
      t.string :s
      t.string :token_sent_name
      t.string :token_sent_symbol
      t.string :token_sent_address
      t.decimal :token_sent_amount
      t.string :token_sent_amount_in_hex

      t.timestamps
    end
  end
end
