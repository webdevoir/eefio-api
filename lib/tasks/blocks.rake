namespace :eefio do
  namespace :blocks do
    desc 'Extracts blocks from the raw_blocks table into the blocks table'
    task extract: :environment do
      puts '___ About to extract blocks from raw_blocks'

      loop do
        raw_blocks = RawBlock.where(block_extracted_at: nil).limit(1000)
        p raw_blocks.map(&:block_number)

        raw_blocks.each(&:extract_block)

        break if raw_blocks.blank?
      end
    end
  end
end
