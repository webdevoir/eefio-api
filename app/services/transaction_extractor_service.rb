class TransactionExtractorService
  class << self
    def extract_transactions_from raw_block:
      puts "==> Extracting Transactions from RawBlock: #{raw_block.block_number}"

      # Work with just the RawBlock’s content JSON blob
      raw_block_content = JSON.parse(raw_block.content).with_indifferent_access

      # Find the associated Block
      block = Block.find_by block_number: raw_block.block_number

      # Get the Transactions out of the RawBlock’s content hash
      raw_transactions = raw_block_content['transactions']


      # Ensure that BOTH happen together:
      # The Transactions are created and the RawBlock is updated
      Transaction.transaction do
        raw_transactions.each do |raw_transaction|
          raw_transaction = raw_transaction.with_indifferent_access
          p raw_transaction
          puts
          puts
          puts '*'*80
          puts
          puts

          # Create a new empty Transaction object
          transaction = block.transactions.new

          # Add associated Block values
          transaction.block_address       = block.address
          transaction.block_number        = block.block_number
          transaction.block_number_in_hex = block.block_number_in_hex

          # TODO: extract token info from events/topics
          # string  token_sent_name:
          # string  token_sent_symbol:
          # string  token_sent_address:
          # string  token_sent_amount_in_hex:
          # decimal token_sent_amount:

          # Keys (on the left) are Transaction attributes (columns in the database on the transactions table)
          # Values (on the right) are RawBlock.content attributes (keys in the JSON blob)
          # Walk through each pair and save the value from the JSON blob into the new Transaction object
          # Don’t convert value at all
          {
            address:                 :hash,
            eth_sent_in_wei_in_hex:  :value,
            from:                    :from,
            gas_price_in_wei_in_hex: :gasPrice,
            gas_provided_in_hex:     :gas,
            index_on_block_in_hex:   :transactionIndex,
            input:                   :input,
            nonce_in_hex:            :nonce,
            r:                       :r,
            s:                       :s,
            to:                      :to,
            v_in_hex:                :v
          }.each do |transaction_attr, raw_transaction_attr|
            transaction.send("#{transaction_attr}=", raw_transaction[raw_transaction_attr])
          end

          # Keys (on the left) are Block attributes (columns in the database on the blocks table)
          # Values (on the right) are RawBlock.content attributes (keys in the JSON blob)
          # Walk with each pair and save the value from the JSON blob into the new Block object
          # Convert value from hexadecimal to an integer
          {
            eth_sent_in_wei:  :value,
            gas_price_in_wei: :gasPrice,
            gas_provided:     :gas,
            index_on_block:   :transactionIndex,
            nonce:            :nonce,
            v:                :v
          }.each do |transaction_attr, raw_transaction_attr|
            transaction.send("#{transaction_attr}=", raw_transaction[raw_transaction_attr].from_hex)
          end

          # Transaction#published_at is a special case because it’s stored as DateTime object
          transaction.published_at                               = block.published_at
          transaction.published_at_in_seconds_since_epoch        = block.published_at_in_seconds_since_epoch
          transaction.published_at_in_seconds_since_epoch_in_hex = block.published_at_in_seconds_since_epoch_in_hex

          # Save the Block to the database
          transaction.save
          puts "+++ Saved Transaction: #{transaction.block_number} [#{transaction.index_on_block}]" if transaction.created_at.present?
        end

        # Mark the associated RawBlock that its Transactions data has been extracted
        raw_block.update transactions_extracted_at: block.transactions.order(index_on_block: :desc).first.created_at
      end
    end

    def transactions_all_extracted?
      RawBlock.with_unextracted_transactions.blank?
    end

    def update_transactions_extracted_up_to_block_number_setting! block_number:
      setting = Setting.transactions_extracted_up_to_block_number
      return if setting.content.to_i == block_number

      puts "+++ Updated Setting: transactions_extracted_up_to_block_number: #{block_number}"
      puts

      setting.update content: block_number
    end
  end
end
