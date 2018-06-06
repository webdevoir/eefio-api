json.prettify!

json.links do
  json.merge! @root.links
end

json.meta do
  json.license       Ethio::LICENSE
  json.url           Ethio::API_URL
  json.documentation Ethio::DOCUMENTATION_URL
  json.contributors  Ethio::CONTRIBUTORS
end

json.jsonapi do
  json.version     Ethio::JSONAPI_VERSION
  json.description Ethio::JSONAPI_DESCRIPTION
end
