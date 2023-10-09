--MIT License
--
--Copyright (c) 2023 SICK AG
--
--Permission is hereby granted, free of charge, to any person obtaining a copy
--of this software and associated documentation files (the "Software"), to deal
--in the Software without restriction, including without limitation the rights
--to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--copies of the Software, and to permit persons to whom the Software is
--furnished to do so, subject to the following conditions:
--
--The above copyright notice and this permission notice shall be included in all
--copies or substantial portions of the Software.
--
--THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
--SOFTWARE.

---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter
--**************************************************************************
--**********************Start Global Scope *********************************
--**************************************************************************

----------------------------------------------------------------------------
-- Logger
_G.logger = Log.SharedLogger.create('ModuleLogger')
_G.logHandle = Log.Handler.create()
_G.logHandle:attachToSharedLogger('ModuleLogger')
_G.logHandle:setConsoleSinkEnabled(false) --> Set to TRUE if CSK_Logger module is not used
_G.logHandle:setLevel("ALL")
_G.logHandle:applyConfig()

--**************************************************************************
--**********************End Global Scope ***********************************
--**************************************************************************

--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

-------------------------------------------------------------------------------------
-- Variables
local m_httpDemo = require("Demo.HTTPDemo")
local m_mqttDemo = require("Demo.MQTTDemo")

----------------------------------------------------------------------------
--- Function that is called as soon as the LiveConnect Client is initialized
local function handleOnClientInitialized()
  -- Part- and serial number of a SICK DT35 IO-Link device. To this device, both profiles are attached.
  local l_partNumber = "1057651"
  local l_serialNumber = "17410401"

   -- MQTT profile (data push)
  m_mqttDemo.addNewMQTTProfile(l_partNumber, l_serialNumber)

  -- HTTP profile (data poll)
  m_httpDemo.addNewHTTPProfile(l_partNumber, l_serialNumber)
end

Script.register('CSK_LiveConnect.OnClientInitialized', handleOnClientInitialized)

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************
