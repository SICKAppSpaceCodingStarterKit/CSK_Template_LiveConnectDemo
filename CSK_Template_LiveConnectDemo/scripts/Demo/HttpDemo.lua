-------------------------------------------------------------------------------------
-- Variables
local m_json = require("Demo.utils.Json")
local m_httpProfileFilePath = "resources/profileHTTPTest.yaml" -- Adapt accordingly
local m_functions = {}

-- Respond to HTTP request
local function httpCallback(request)
  local l_response = CSK_LiveConnect.Response.create()
  local l_header = CSK_LiveConnect.Header.create()
  CSK_LiveConnect.Header.setKey(l_header, "Content-Type")
  CSK_LiveConnect.Header.setValue(l_header, "application/json")

  l_response:setHeaders({l_header})
  l_response:setStatusCode(200)

  local l_responsePayload = {}
  l_responsePayload["timestamp"] = DateTime.getDateTime()
  l_responsePayload["index"] = math.random(0,255)
  l_responsePayload["data"] = "Hello from the edge side."

  l_response:setContent(m_json.encode(l_responsePayload))
  return l_response
end

-------------------------------------------------------------------------------------
-- Add HTTP application profile
function m_functions.addNewHTTPProfile(partNumber, serialNumber)
  -- Create HTTP profile according the "profileHTTPTest.yaml"
  local l_httpProfile =  CSK_LiveConnect.HTTPProfile.create()
  l_httpProfile:setName("LiveConnect HTTP test profile")
  l_httpProfile:setDescription("Profile to test bi-direction communication between the server and the client")
  l_httpProfile:setVersion("0.2.0")
  l_httpProfile:setUUID("68f372d5-607c-4e16-b137-63af9fadaaa5")
  l_httpProfile:setOpenAPISpecification(File.open(m_httpProfileFilePath, "rb"):read())
  l_httpProfile:setServiceLocation("http-test")

  -- Endpoint definition
  local l_uri = "getwithoutparam"
  local l_crownName = Engine.getCurrentAppName() .. "." .. l_uri
  local l_endpoint = CSK_LiveConnect.HTTPProfile.Endpoint.create()
  l_endpoint:setHandlerFunction(l_crownName)
  l_endpoint:setMethod("GET")
  l_endpoint:setURI(l_uri)

  -- Register callback function, which will be called to answer the HTTP request
  Script.serveFunction(l_crownName, httpCallback, "object:CSK_LiveConnect.Request", "object:CSK_LiveConnect.Response")

  -- Add endpoints
  CSK_LiveConnect.HTTPProfile.setEndpoints(l_httpProfile, {l_endpoint})

  -- Register application profile
  CSK_LiveConnect.addHTTPProfile(partNumber, serialNumber, l_httpProfile)
end

return m_functions