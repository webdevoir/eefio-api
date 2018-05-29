class Block < ApplicationRecord
  validates :block_number,        presence: true, uniqueness: true
  validates :block_number_in_hex, presence: true, uniqueness: true
  validates :address,             presence: true, uniqueness: true

  URL_NAMESPACE = 'blocks'.freeze

  def links identifier:
    links = {}

    links[:self]     = url_for(identifier: identifier, block: self)
    links[:next]     = url_for(identifier: identifier, block: next_block)     unless next_block     == self
    links[:previous] = url_for(identifier: identifier, block: previous_block) unless previous_block == self
    links[:last]     = url_for(identifier: identifier, block: last_block)

    links
  end

  def url_for block:, identifier:
    namespace_identifier = block.address
    namespace_identifier = block.block_number.to_i if identifier == :block_number

    [URL::ETHIO_API_BASE_URL, URL_NAMESPACE, namespace_identifier].join('/')
  end

  def previous_block
    Block.order(block_number: :desc).limit(2).last
  end

  def next_block
    Block.order(block_number: :asc).limit(2).last
  end

  def last_block
    Block.order(block_number: :desc).limit(1).last
  end
end
