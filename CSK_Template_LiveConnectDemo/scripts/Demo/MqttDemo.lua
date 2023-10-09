-------------------------------------------------------------------------------------
-- Variables
local m_timer = Timer.create()
local m_json = require("Demo.utils.Json")
local m_mqttProfileFilePath = "resources/profileMQTTTest.yaml" -- Adapt accordingly
local m_functions = {}

-------------------------------------------------------------------------------------
-- Payload to be sent at a specific interval
local function sendMQTTData(partNumber, serialNumber, topic)
  local l_payload = {}
  l_payload.timestamp = DateTime.getDateTime()
  l_payload.index = math.random(0,255)
  l_payload.data = "Payload from the edge side"

  local l_payloadJson = m_json.encode(l_payload)
  CSK_LiveConnect.publishMQTTData(topic, partNumber, serialNumber, l_payloadJson)
end

-------------------------------------------------------------------------------------
-- Add MQTT application profile
function m_functions.addNewMQTTProfile(partNumber, serialNumber)
  -- Create MQTT profile according the "profileMQTTTest.yaml"
  local l_mqttProfile = CSK_LiveConnect.MQTTProfile.create()
  local l_topic = "sick/device/mqtt-test"
  l_mqttProfile:setUUID("55aa8083-24dc-41aa-bad0-ee28d5892d9d")
  l_mqttProfile:setName("LiveConnect MQTT test profile")
  l_mqttProfile:setDescription("Profile to test data push mechanism")
  l_mqttProfile:setBaseTopic(l_topic)
  l_mqttProfile:setAsyncAPISpecification(File.open(m_mqttProfileFilePath, "rb"):read())
  l_mqttProfile:setVersion("0.1.0")

  -- Payload definition
  local l_sendData = function()
    return sendMQTTData(partNumber, serialNumber, l_topic)
  end
  m_timer:setExpirationTime(5000)
  m_timer:setPeriodic(true)
  m_timer:register("OnExpired", l_sendData)
  m_timer:start()

  -- Register application profile
  CSK_LiveConnect.addMQTTProfile(partNumber, serialNumber, l_mqttProfile)
end

return m_functions