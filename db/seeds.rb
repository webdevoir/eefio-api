# Add a setting to save the block_number of the last known place
# where the raw_blocks table was in sync with the blockchain
puts 'Creating Setting: raw_blocks_synced_at_block_number'
Setting.find_or_create_by name: 'raw_blocks_synced_at_block_number' do |setting|
  setting.content     = 0
  setting.data_type   = 'Integer'
  setting.description = 'When the raw_blocks table has the same number of records as the largest
                         `block_number` (minus one) in the `raw_blocks` table, then the table is in
                         sync with the blockchain. At least, up to that `block_number`. When that
                         moment happens, this `Setting` gets updated to that that `block_number`. That
                         way, future jobs will know to never search below that `block_number` for
                         missing blocks when trying to sync with the blockchain again.'
end

# Add a setting to save the block_number of the last known place where
# all raw_blocks at and below that block_number have been extracted to blocks
puts 'Creating Setting: blocks_extracted_up_to_block_number'
Setting.find_or_create_by name: 'blocks_extracted_up_to_block_number' do |setting|
  setting.content     = 0
  setting.data_type   = 'Integer'
  setting.description = 'When all raw_blocks at and below that block_number have been extracted
                         to blocks. When that moment happens, this `Setting` gets updated to that
                         that `block_number`. That way, future jobs will know to never search
                         below that `block_number` for raw_blocks to extract again.'
end

# Add a setting to save the block_number of the last known place where
# all raw_blocks at and below that block_number have been extracted to transactions
puts 'Creating Setting: transactions_extracted_up_to_block_number'
Setting.find_or_create_by name: 'transactions_extracted_up_to_block_number' do |setting|
  setting.content     = 0
  setting.data_type   = 'Integer'
  setting.description = 'When all raw_blocks at and below that block_number have been extracted
                         to transactions. When that moment happens, this `Setting` gets updated to that
                         that `block_number`. That way, future jobs will know to never search
                         below that `block_number` for raw_blocks to extract again.'
end


puts 'All done.'
puts 'Next, run:'
puts '    rake eefio:blockchain:sync'
