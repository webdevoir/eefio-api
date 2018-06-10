class RootController < ApplicationController
  def index
    @links = { self: Ethio::API_URL }

    @endpoints = I18n.t('api.endpoints').map do |endpoint|
      {
        name:         endpoint[:name],
        http_verb:    'GET',
        url:          api_url_for(name: endpoint[:name]),
        documenation: documenation_url_for(name: endpoint[:name]),
        description:  endpoint[:description],
      }
    end
  end

  def documenation_url_for name:
    [Ethio::DOCUMENTATION_URL, name.split('#')].join('/')
  end

  def api_url_for name:
    [Ethio::API_URL, name.split('#')].join('/').gsub('/one', '/:identifier')
  end
end
