class TransactionsController < ApplicationController
  before_action :set_id_from_params, only: [:show, :raw]
  before_action :set_identifier,     only: [:show, :raw]
  before_action :set_transaction,    only: [:show, :raw]
  before_action :set_links,          only: [:show, :raw]

  def show
    set_documentation_url route: :one
  end

  def raw
    set_documentation_url route: :raw
    @raw = JSON.parse @transaction.raw
  end

  private

  def set_documentation_url route:
    @documentation = [Eefio::DOCUMENTATION_URL, Transaction::URL_NAMESPACE, route.to_s].join('/')
  end

  def set_id_from_params
    @id = params.permit(:id)[:id].strip.downcase
  end

  def set_identifier
    @identifier = @id.to_sym == :latest ? :latest : :address
  end

  def set_transaction
    @transaction =
      if @identifier == :latest
        Transaction.latest_transaction
      else
        Transaction.find_by address: @id
      end
  end

  def set_links
    @links = @transaction.links identifier: @identifier, raw: action_name == 'raw'
  end
end
