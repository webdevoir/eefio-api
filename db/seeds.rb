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


puts 'All done.'
puts 'Next, run:'
puts '    rake ethio:blockchain:sync'
