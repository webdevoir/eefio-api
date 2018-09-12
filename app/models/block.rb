class Block < ApplicationRecord
  validates :block_number,        presence: true
  validates :block_number_in_hex, presence: true
  validates :address,             presence: true

  URL_NAMESPACE = 'blocks'.freeze

  class << self
    def first_block
      @first_block ||= Block.find_by block_number: 0
    end

    def latest_block
      @latest_block ||= Block.find_by block_number: Setting.blocks_extracted_up_to_block_number.content.to_i
    end

    def latest_block_number
      latest_block&.block_number || 0
    end
  end

  def links identifier:
    links = {}

    links[:self]  = url_for(identifier: identifier, block: self)
    links[:first] = url_for(identifier: identifier, block: Block.first_block)

    links[:previous] = url_for(identifier: identifier, block: previous_block) unless previous_block == self || previous_block.blank?

    links[:next] = url_for(identifier: identifier, block: next_block) unless next_block == self || next_block.blank?

    links[:last] = url_for(identifier: identifier, block: Block.latest_block)

    links
  end

  def next_block
    Block.find_by(block_number: block_number + 1)
  end

  def previous_block
    Block.find_by(block_number: block_number - 1)
  end

  def url_for block:, identifier:
    namespace_identifier = block.address
    namespace_identifier = block.block_number.to_i if identifier == :block_number

    [Eefio::API_URL, URL_NAMESPACE, namespace_identifier].join('/')
  end
end
