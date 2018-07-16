class Block < ApplicationRecord
  validates :block_number,        presence: true, uniqueness: true
  validates :block_number_in_hex, presence: true, uniqueness: true
  validates :address,             presence: true, uniqueness: true

  URL_NAMESPACE = 'blocks'.freeze

  class << self
    def first_block
      Block.find_by block_number: 0
    end

    def last_block
      Block.order(block_number: :desc).limit(1).last
    end
  end

  def links identifier:
    links = {}

    links[:self]  = url_for(identifier: identifier, block: self)
    links[:first] = url_for(identifier: identifier, block: Block.first_block)

    unless previous_block == self || previous_block.blank?
      links[:previous] = url_for(identifier: identifier, block: previous_block)
    end

    unless next_block == self || next_block.blank?
      links[:next] = url_for(identifier: identifier, block: next_block)
    end

    links[:last] = url_for(identifier: identifier, block: Block.last_block)

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
