class BlocksController < ApplicationController
  def show_latest
    @block = Block.order(block_number: :desc).limit(1).first
    render json: @block
  end

  def index
  end
end
