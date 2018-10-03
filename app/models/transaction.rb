class Transaction < ApplicationRecord
  belongs_to :block

  scope :oldest, -> { order(index_on_block: :asc).limit(1) }
  scope :latest, -> { order(index_on_block: :desc).limit(1) }

  URL_NAMESPACE = 'transactions'.freeze

  class << self
    def first_transaction
      @first_transaction ||=
        Transaction.where(index_on_block: 0).order(block_number: :asc).limit(1).first
    end

    def latest_transaction
      @latest_transaction ||= Block.latest_block.transactions.latest.last
    end
  end

  def links identifier:, raw:
    links = {}

    {
      self:     self,
      first:    Transaction.first_transaction,
      previous: previous_transaction,
      next:     next_transaction,
      last:     Transaction.latest_transaction
    }.each do |name, transaction|
      links[name] = url_for(transaction: transaction, raw: raw) if transaction.present?
    end

    links
  end

  def next_transaction
    return block.transactions[index_on_block + 1] unless block.transactions.latest.last == self

    other_block = block.next_block

    loop do
      return nil if other_block.blank?

      break if other_block.transactions.present?
      other_block = other_block.next_block
    end

    other_block.transactions.oldest.last
  end

  def previous_transaction
    return block.transactions[index_on_block - 1] unless index_on_block.zero?

    other_block = block.previous_block

    loop do
      return nil if other_block.blank?

      break if other_block.transactions.present?
      other_block = other_block.previous_block
    end

    other_block.transactions.latest.last
  end

  def url_for transaction:, raw:
    raw_path = raw ? 'raw' : nil

    [Eefio::API_URL, URL_NAMESPACE, transaction.address, raw_path].compact.join('/')
  end

  def raw
    raw_block         = RawBlock.find_by(block_number: block_number)
    raw_block_content = JSON.parse(raw_block.content).with_indifferent_access
    transactions      = raw_block_content[:transactions]

    transactions[index_on_block].to_json
  end
end
