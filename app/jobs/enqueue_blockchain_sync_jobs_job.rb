class EnqueueBlockchainSyncJobsJob < ApplicationJob
  queue_as :default

  def perform starting_block_number:, ending_block_number:
    puts "==> Enqueueing jobs for block numbers: #{starting_block_number} - #{ending_block_number}"
    BlockImporterService.get_blocks_from_blockchain starting_block_number: starting_block_number,
                                                    ending_block_number:   ending_block_number
  end
end
