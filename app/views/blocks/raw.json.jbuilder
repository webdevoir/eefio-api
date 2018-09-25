json.prettify!

json.links do
  json.merge! @links
end

json.data do
  json.block do
    json.raw @raw
  end
end

json.meta do
  json.description   Eefio::API_DESCRIPTION
  json.version       Eefio::API_VERSION
  json.license       Eefio::LICENSE
  json.url           Eefio::API_URL
  json.contributors  Eefio::CONTRIBUTORS
  json.documentation @documentation
  json.contact       Eefio::CONTACT_INFO
end

json.jsonapi do
  json.version     Eefio::JSONAPI_VERSION
  json.description Eefio::JSONAPI_DESCRIPTION
end
