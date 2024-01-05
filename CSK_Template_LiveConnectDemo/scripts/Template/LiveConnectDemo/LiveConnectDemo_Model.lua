---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter
--*****************************************************************
-- Inside of this script, you will find the module definition
-- including its parameters and functions
--*****************************************************************

--**************************************************************************
--**********************Start Global Scope *********************************
--**************************************************************************
local nameOfModule = 'CSK_LiveConnectDemo'

local liveConnectDemo_Model = {}

-- Check if CSK_UserManagement module can be used if wanted
liveConnectDemo_Model.userManagementModuleAvailable = CSK_UserManagement ~= nil or false

-- Check if CSK_PersistentData module can be used if wanted
liveConnectDemo_Model.persistentModuleAvailable = CSK_PersistentData ~= nil or false

-- Default values for persistent data
-- If available, following values will be updated from data of CSK_PersistentData module (check CSK_PersistentData module for this)
liveConnectDemo_Model.parametersName = 'CSK_LiveConnectDemo_Parameter' -- name of parameter dataset to be used for this module
liveConnectDemo_Model.parameterLoadOnReboot = false -- Status if parameter dataset should be loaded on app/device reboot

-- Load script to communicate with the LiveConnectDemo_Model interface and give access
-- to the LiveConnectDemo_Model object.
-- Check / edit this script to see/edit functions which communicate with the UI
local setLiveConnectDemo_ModelHandle = require('Template/LiveConnectDemo/LiveConnectDemo_Controller')
setLiveConnectDemo_ModelHandle(liveConnectDemo_Model)

--Loading helper functions if needed
liveConnectDemo_Model.helperFuncs = require('Template/LiveConnectDemo/helper/funcs')

-- Create parameters / instances for this module
liveConnectDemo_Model.timer = Timer.create()
liveConnectDemo_Model.json = require("Template/LiveConnectDemo/utils.Lunajson")
liveConnectDemo_Model.mqttProfileFilePath = "resources/sampleProfiles/profileMQTTTest.yaml"
liveConnectDemo_Model.httpProfileFilePath = "resources/sampleProfiles/profileHTTPTest.yaml"

liveConnectDemo_Model.partNumber = '1057651' -- Part number of profile to add, e.g. of a DT35 sensor
liveConnectDemo_Model.serialNumber = '17410401' -- Serial number of profile to add, e.g. of a DT35 sensor

-- Parameters to be saved permanently if wanted
liveConnectDemo_Model.parameters = {}

--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

-- ##############################
-- ## MQTT profile (data push) ##
-- ##############################

-------------------------------------------------------------------------------------
-- Payload to be sent at a specific interval
local function sendMQTTData(partNumber, serialNumber, topic)
  local l_payload = {}
  l_payload.timestamp = DateTime.getDateTime()
  l_payload.index = math.random(0,255)
  l_payload.data = "Payload from the edge side"

  local l_payloadJson = liveConnectDemo_Model.json.encode(l_payload)
  CSK_LiveConnect.publishMQTTData(topic, partNumber, serialNumber, l_payloadJson)
end
liveConnectDemo_Model.sendMQTTData = sendMQTTData

-------------------------------------------------------------------------------------
-- Add MQTT application profile
local function addNewMQTTProfile(partNumber, serialNumber)
  -- Profile definition
  local l_mqttProfile = CSK_LiveConnect.MQTTProfile.create()
  local l_topic = "sick/device/mqtt-test"
  l_mqttProfile:setUUID("55aa8083-24dc-41aa-bad0-ee28d5892d9d")
  l_mqttProfile:setName("LiveConnect MQTT test profile")
  l_mqttProfile:setDescription("Profile to test data push mechanism")
  l_mqttProfile:setBaseTopic(l_topic)
  l_mqttProfile:setAsyncAPISpecification(File.open(liveConnectDemo_Model.mqttProfileFilePath, "rb"):read())
  l_mqttProfile:setVersion("0.1.0")

  -- Payload definition
  local l_sendData = function()
    return sendMQTTData(partNumber, serialNumber, l_topic)
  end
  liveConnectDemo_Model.timer:setExpirationTime(5000)
  liveConnectDemo_Model.timer:setPeriodic(true)
  liveConnectDemo_Model.timer:register("OnExpired", l_sendData)
  liveConnectDemo_Model.timer:start()

  -- Register application profile
  CSK_LiveConnect.addMQTTProfile(partNumber, serialNumber, l_mqttProfile)
end
Script.serveFunction('CSK_LiveConnectDemo.addNewMQTTProfile', addNewMQTTProfile)
liveConnectDemo_Model.addNewMQTTProfile = addNewMQTTProfile
-------------------------------------------------------------------------------------
-- ######################
-- ## MQTT profile END ##
-- ######################
-------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------
-- ##############################
-- ## HTTP profile (data poll) ##
-- ##############################
-------------------------------------------------------------------------------------
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
  l_responsePayload["data"] = "Response payload from the edge side"

  l_response:setContent(liveConnectDemo_Model.json.encode(l_responsePayload))
  return l_response
end
liveConnectDemo_Model.httpCallback = httpCallback

-------------------------------------------------------------------------------------
-- Add HTTP application profile
local function addNewHTTPProfile(partNumber, serialNumber)
  local l_httpProfile =  CSK_LiveConnect.HTTPProfile.create()
  l_httpProfile:setName("LiveConnect HTTP test profile")
  l_httpProfile:setDescription("Profile to test bi-direction communication between the server and the client")
  l_httpProfile:setVersion("0.2.0")
  l_httpProfile:setUUID("68f372d5-607c-4e16-b137-63af9fadaaa5")
  l_httpProfile:setOpenAPISpecification(File.open(liveConnectDemo_Model.httpProfileFilePath, "rb"):read())
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
liveConnectDemo_Model.addNewHTTPProfile = addNewHTTPProfile
Script.serveFunction('CSK_LiveConnectDemo.addNewHTTPProfile', addNewHTTPProfile)

-------------------------------------------------------------------------------------
-- ######################
-- ## HTTP profile END ##
-- ######################
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------

--*************************************************************************
--********************** End Function Scope *******************************
--*************************************************************************

return liveConnectDemo_Model
