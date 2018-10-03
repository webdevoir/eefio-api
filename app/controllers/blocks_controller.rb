class BlocksController < ApplicationController
  before_action :set_id_from_params
  before_action :set_identifier
  before_action :set_block
  before_action :set_links, only: [:show, :raw, :transactions]

  def show
    set_documentation_url route: :one

    @links[:raw]          = @block.url_for block: @block, identifier: @identifier, suffix: :raw
    @links[:transactions] = @block.url_for block: @block, identifier: @identifier, suffix: :transactions
  end

  def raw
    set_documentation_url route: :raw
    @raw = JSON.parse @block.raw

    @links[:block] = @block.url_for block: @block, identifier: @identifier, suffix: nil
  end

  def transactions
    set_documentation_url route: :transactions
    @transactions = @block.transactions.sorted

    @links[:block] = @block.url_for block: @block, identifier: @identifier, suffix: nil
  end

  def transaction
    set_documentation_url route: :transaction

    index = params.permit(:index)[:index].strip.downcase
    @transaction = @block.transactions.where(index_on_block: index).first
  end

  private

  def set_documentation_url route:
    @documentation = [Eefio::DOCUMENTATION_URL, Block::URL_NAMESPACE, route.to_s].join('/')
  end

  def set_id_from_params
    @id = params.permit(:id)[:id].strip.downcase
  end

  def set_identifier
    @identifier =
      if @id == 'latest'
        :latest
      elsif @id[0..1] == '0x'
        :address
      else
        :block_number
      end
  end

  def set_block
    @block =
      case @identifier
      when :latest
        Block.latest_block
      when :address
        Block.find_by address: @id
      when :block_number
        Block.find_by block_number: @id
      end
  end

  def set_links
    suffix = action_name if action_name =~ /raw|transactions/

    @links = @block.links identifier: @identifier, suffix: suffix
  end
end
