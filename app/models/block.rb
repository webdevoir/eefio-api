class Block < ApplicationRecord
  validates :block_number,        presence: true
  validates :block_number_in_hex, presence: true
  validates :address,             presence: true

  has_many :transactions, dependent: :destroy

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

  def links identifier:, suffix:
    links = {}

    {
      self:     self,
      first:    Block.first_block,
      previous: previous_block,
      next:     next_block,
      last:     Block.latest_block
    }.each do |name, block|
      links[name] = url_for(identifier: identifier, block: block, suffix: suffix) if block.present?
    end

    links
  end

  def previous_block
    @previous_block ||= Block.find_by block_number: block_number - 1
  end

  def next_block
    @next_block ||= Block.find_by block_number: block_number + 1
  end

  def url_for block:, identifier:, suffix:
    namespace_identifier = block.address
    namespace_identifier = block.block_number.to_i if identifier == :block_number

    [Eefio::API_URL, URL_NAMESPACE, namespace_identifier, suffix].compact.join('/')
  end

  def raw
    RawBlock.find_by(block_number: block_number).content
  end

  def transactions_by_address
    transactions.order(index_on_block: :asc).map(&:address)
  end
end
