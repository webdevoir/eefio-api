json.prettify!

json.links do
  json.merge! @links
end

json.data do
  json.endpoints @endpoints
end

json.meta do
  json.version       Eefio::API_VERSION
  json.license       Eefio::LICENSE
  json.url           Eefio::API_URL
  json.contributors  Eefio::CONTRIBUTORS
  json.documentation Eefio::DOCUMENTATION_URL
  json.contact       Eefio::CONTACT_INFO
end

json.jsonapi do
  json.version     Eefio::JSONAPI_VERSION
  json.description Eefio::JSONAPI_DESCRIPTION
end
