namespace :eefio do
  namespace :transactions do
    desc 'Extracts Transactions from the raw_blocks table into the transactions table'
    task extract: :environment do
      puts
      puts '___ Extracting Transactions…'

      # Extract all of the Transactions from RawBlocks table
      loop do
        puts
        unextracted_raw_block = RawBlock.with_unextracted_transactions
        break if unextracted_raw_block.blank?

        puts '==> Finding RawBlock to extract…'
        TransactionExtractorService.extract_transactions_from raw_block: unextracted_raw_block
      end

      # When all RawBlocks are extracted, update Setting, then exit!
      if TransactionExtractorService.transactions_all_extracted?
        latest_extracted_transactions_block_number = Transaction.order(block_number: :desc).limit(1).first&.block_number.to_i

        if latest_extracted_transactions_block_number.present?
          TransactionExtractorService.update_transactions_extracted_up_to_block_number_setting! block_number: latest_extracted_transactions_block_number

          puts
          puts "___ Latest extracted Block: #{latest_extracted_transactions_block_number}"
        end
      end

      puts '___ FINISHED!'
      puts
    end
  end
end
