namespace :eefio do
  namespace :blocks do
    desc 'Extracts blocks from the raw_blocks table into the blocks table'
    task extract: :environment do
      puts '___ About to extract blocks from raw_blocks'

      RawBlock.where(block_extracted_at: nil).each_slice(1000) do |slice|
        slice.each do |raw_block|
          raw_block.extract_block
        end
      end
    end
  end
end
