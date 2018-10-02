class RootController < ApplicationController
  def index
    @links = {
      self:          Eefio::API_URL,
      blocks_latest: api_url_for(path: 'blocks/latest'),
      blocks_first:  api_url_for(path: 'blocks/0')
    }

    @endpoints = I18n.t('api.endpoints').map do |endpoint|
      {
        name:          endpoint[:name],
        http_verb:     'GET',
        url:           api_url_for(path: endpoint[:path]),
        documentation: documentation_url_for(name: endpoint[:name]),
        description:   endpoint[:description]
      }
    end
  end

  private

  def documentation_url_for name:
    [Eefio::DOCUMENTATION_URL, name.split('#')].join('/')
  end

  def api_url_for path:
    [Eefio::API_URL, path].join('/')
  end
end
