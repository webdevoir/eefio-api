namespace :eefio do
  namespace :blocks do
    desc 'Extracts blocks from the raw_blocks table into the blocks table'
    task extract: :environment do
      latest_block_number           = Block.latest_block_number
      latest_extracted_block_number = Setting.blocks_extracted_up_to_block_number.content.to_i

      puts
      puts '___ Extracting Blocks…'
      puts
      puts "___ Latest Block block_number:         #{latest_block_number}"
      puts "___ Last extracted Block block_number: #{latest_extracted_block_number}"
      puts

      # Extract all of the Blocks from RawBlocks table
      loop do
        break if BlockExtractorService.blocks_all_extracted?

        puts
        puts '___ Not all Eefio RawBlocks are extracted to Blocks '
        puts

        unextracted_raw_block = RawBlock.limit(1).where(block_extracted_at: nil).first

        break if unextracted_raw_block.blank?

        puts "___ Extracting Block with block_number: #{unextracted_raw_block.block_number}"
        puts

        BlockExtractorService.extract_blocks_from_raw_blocks block_numbers: [unextracted_raw_block.block_number]
      end

      # Once RawBlocks is in sync with the blockchain, then quit!
      if BlockExtractorService.blocks_all_extracted?
        latest_extracted_block_number = Setting.blocks_extracted_up_to_block_number.content.to_i
        puts
        puts "___ FINISHED! Latest extracted Block: #{latest_extracted_block_number}"
      end

      puts
    end
  end
end
