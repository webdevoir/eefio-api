json.prettify!

json.links do
  json.merge! @links
end

json.data do
  json.endpoints @endpoints
end

json.meta do
  json.version       Ethio::API_VERSION
  json.license       Ethio::LICENSE
  json.url           Ethio::API_URL
  json.contributors  Ethio::CONTRIBUTORS
  json.documentation Ethio::DOCUMENTATION_URL
end

json.jsonapi do
  json.version     Ethio::JSONAPI_VERSION
  json.description Ethio::JSONAPI_DESCRIPTION
end
