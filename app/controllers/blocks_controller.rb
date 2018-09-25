class BlocksController < ApplicationController
  before_action :set_id_from_params, only: [:show, :raw]
  before_action :set_identifier,     only: [:show, :raw]
  before_action :set_block,          only: [:show, :raw]
  before_action :set_links,          only: [:show, :raw]

  def show
    set_documentation_url route: :one
  end

  def raw
    set_documentation_url route: :raw
    @raw = JSON.parse @block.raw
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
    @links = @block.links identifier: @identifier, raw: action_name == 'raw'
  end
end
