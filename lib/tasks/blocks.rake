namespace :eefio do
  namespace :blocks do
    desc 'Extracts blocks from the raw_blocks table into the blocks table'
    task extract: :environment do
      puts
      puts '___ Extracting Blocks…'

      # Extract all of the Blocks from RawBlocks table
      loop do
        puts
        break if BlockExtractorService.blocks_all_extracted?

        puts "==> Finding RawBlock to extract…"
        BlockExtractorService.extract_block_from raw_block: RawBlock.an_unextracted_one
      end

      # When all RawBlocks are extracted, update Setting, then exit!
      if BlockExtractorService.blocks_all_extracted?
        latest_extracted_block_number = Block.order(block_number: :desc).first.block_number

        BlockExtractorService.update_blocks_extracted_up_to_block_number_setting! block_number: latest_extracted_block_number

        puts
        puts "___ FINISHED! Latest extracted Block: #{latest_extracted_block_number}"
      end

      puts
    end
  end
end
