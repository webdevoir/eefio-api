class BlocksController < ApplicationController
  def show
    id = params[:id].strip.downcase

    @identifier =
      if id == 'latest'
        :latest
      elsif id[0..1] == '0x'
        :address
      else
        :block_number
      end

    @block =
      case @identifier
      when :latest
        Block.order(block_number: :desc).limit(1).first
      when :address
        Block.find_by address: params[:id]
      when :block_number
        Block.find_by block_number: params[:id]
      end

    @documentation = [Ethio::DOCUMENTATION_URL, Block::URL_NAMESPACE, 'one'].join('/')
  end
end
