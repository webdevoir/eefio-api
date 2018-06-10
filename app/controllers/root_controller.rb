class RootController < ApplicationController
  def index
    @links = { self: Ethio::API_URL }
  end
end
