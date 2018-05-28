class BlocksController < ApplicationController
  def show_latest
    @block = Block.order(block_number: :desc).limit(1).first

    render json: @block
  end

  def show
    @block =
      if params[:id].strip.downcase[0..1] == '0x'
        Block.find_by(address: params[:id])
      else
        Block.find_by(block_number: params[:id])
      end

    render json: @block
  end

  def index
  end
end
