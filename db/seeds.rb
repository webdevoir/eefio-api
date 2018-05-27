require 'concurrent'

# Add a setting to save the block_number of the last known place
# where the database was in sync with the blockchain
puts 'Creating Setting: raw_blocks_previous_synced_at_block_number'
Setting.find_or_create_by name: 'raw_blocks_previous_synced_at_block_number' do |setting|
  setting.content     = 0
  setting.data_type   = 'Integer'
  setting.description = 'When the database has the same number of RawBlocks as the largest
                         `block_number` (minus one) in the `raw_blocks` table, then the table
                         is in sync with the blockchain. At least, up to that `block_number`.
                         When that moment happens, this `Setting` gets updated to that that
                         `block_number`. That way, future jobs will know to never search below
                         that `block_number` for missing blocks when trying to sync with the
                         blockchain again.'
end


puts
puts "RawBlocks now in the database: #{BlockImporterService.raw_blocks_count}"
puts "Latest RawBlock block_number:  #{BlockImporterService.latest_raw_block_number}"
puts

BlockImporterService.save_in_sync_block_number

# Set the lowest block number to be fetched
last_in_sync_block_number  = Setting.find_by(name: 'raw_blocks_previous_synced_at_block_number').content
lowest_block_number_needed = last_in_sync_block_number.to_i + 1

BlockImporterService.get_blocks_from_blockchain starting_block_number: lowest_block_number_needed

puts
puts "When in sync, latest block number is -1 of RawBlocks count"
puts "RawBlocks now in the database:                 #{BlockImporterService.raw_blocks_count}"
puts "Latest block on blockchain (at start of sync): #{BlockImporterService.latest_block_number}"
puts
