namespace :eefio do
  namespace :raw_blocks do
    desc 'Delete duplicate raw_blocks from the raw_blocks table'
    task dedupe: :environment do
      before_raw_block_count               = RawBlock.count
      before_raw_block_latest_block_number = RawBlock.latest_block_number

      (0..RawBlock.latest_block_number).each_slice(1000) do |block_numbers|
        block_numbers.each do |block_number|
          raw_blocks = RawBlock.where(block_number: block_number)
          puts "==> RawBlocks at ID #{block_number}: #{raw_blocks.length}"

          if raw_blocks.length > 1
            puts "!!! Deleting #{raw_blocks.length - 1} extra RawBlocks at ID #{block_number}"
            raw_blocks[1..-1].each(&:destroy)
          end
        end
      end

      after_raw_block_count               = RawBlock.count
      after_raw_block_latest_block_number = RawBlock.latest_block_number

      puts 'Total RawBlocks'
      puts "Before: #{before_raw_block_count}"
      puts "After:  #{after_raw_block_count}"
      puts
      puts 'Latest RawBlock block_number:'
      puts "Before: #{before_raw_block_latest_block_number}"
      puts "After:  #{after_raw_block_latest_block_number}"
      puts
    end
  end
end
