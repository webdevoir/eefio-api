class ImportRawBlockFromBlockchainJob < ApplicationJob
  queue_as :default

  after_perform :after_perform

  def perform block_number:
    BlockImporterService.get_and_save_raw_block block_number
  end
end
