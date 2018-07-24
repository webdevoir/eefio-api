class ImportRawBlockFromBlockchainJob < ApplicationJob
  queue_as :default

  def perform block_number:
    BlockImporterService.get_and_save_raw_block block_number
  end
end
