---@diagnostic disable: undefined-global, redundant-parameter, missing-parameter

--***************************************************************
-- Inside of this script, you will find the necessary functions,
-- variables and events to communicate with the LiveConnectDemo_Model
--***************************************************************

--**************************************************************************
--************************ Start Global Scope ******************************
--**************************************************************************
local nameOfModule = 'CSK_LiveConnectDemo'

-- Timer to update UI via events after page was loaded
local tmrLiveConnectDemo = Timer.create()
tmrLiveConnectDemo:setExpirationTime(300)
tmrLiveConnectDemo:setPeriodic(false)

-- Reference to global handle
local liveConnectDemo_Model

-- ************************ UI Events Start ********************************

Script.serveEvent('CSK_LiveConnectDemo.OnNewStatusPartNumber', 'LiveConnectDemo_OnNewStatusPartNumber')
Script.serveEvent('CSK_LiveConnectDemo.OnNewStatusSerialNumber', 'LiveConnectDemo_OnNewStatusSerialNumber')

Script.serveEvent("CSK_LiveConnectDemo.OnNewStatusLoadParameterOnReboot", "LiveConnectDemo_OnNewStatusLoadParameterOnReboot")
Script.serveEvent("CSK_LiveConnectDemo.OnPersistentDataModuleAvailable", "LiveConnectDemo_OnPersistentDataModuleAvailable")
Script.serveEvent("CSK_LiveConnectDemo.OnNewParameterName", "LiveConnectDemo_OnNewParameterName")
Script.serveEvent("CSK_LiveConnectDemo.OnDataLoadedOnReboot", "LiveConnectDemo_OnDataLoadedOnReboot")

Script.serveEvent('CSK_LiveConnectDemo.OnUserLevelOperatorActive', 'LiveConnectDemo_OnUserLevelOperatorActive')
Script.serveEvent('CSK_LiveConnectDemo.OnUserLevelMaintenanceActive', 'LiveConnectDemo_OnUserLevelMaintenanceActive')
Script.serveEvent('CSK_LiveConnectDemo.OnUserLevelServiceActive', 'LiveConnectDemo_OnUserLevelServiceActive')
Script.serveEvent('CSK_LiveConnectDemo.OnUserLevelAdminActive', 'LiveConnectDemo_OnUserLevelAdminActive')

-- ************************ UI Events End **********************************
--**************************************************************************
--********************** End Global Scope **********************************
--**************************************************************************
--**********************Start Function Scope *******************************
--**************************************************************************

-- Functions to forward logged in user roles via CSK_UserManagement module (if available)
-- ***********************************************
--- Function to react on status change of Operator user level
---@param status boolean Status if Operator level is active
local function handleOnUserLevelOperatorActive(status)
  Script.notifyEvent("LiveConnectDemo_OnUserLevelOperatorActive", status)
end

--- Function to react on status change of Maintenance user level
---@param status boolean Status if Maintenance level is active
local function handleOnUserLevelMaintenanceActive(status)
  Script.notifyEvent("LiveConnectDemo_OnUserLevelMaintenanceActive", status)
end

--- Function to react on status change of Service user level
---@param status boolean Status if Service level is active
local function handleOnUserLevelServiceActive(status)
  Script.notifyEvent("LiveConnectDemo_OnUserLevelServiceActive", status)
end

--- Function to react on status change of Admin user level
---@param status boolean Status if Admin level is active
local function handleOnUserLevelAdminActive(status)
  Script.notifyEvent("LiveConnectDemo_OnUserLevelAdminActive", status)
end

--- Function to get access to the liveConnectDemo_Model object
---@param handle handle Handle of liveConnectDemo_Model object
local function setLiveConnectDemo_Model_Handle(handle)
  liveConnectDemo_Model = handle
  if liveConnectDemo_Model.userManagementModuleAvailable then
    -- Register on events of CSK_UserManagement module if available
    Script.register('CSK_UserManagement.OnUserLevelOperatorActive', handleOnUserLevelOperatorActive)
    Script.register('CSK_UserManagement.OnUserLevelMaintenanceActive', handleOnUserLevelMaintenanceActive)
    Script.register('CSK_UserManagement.OnUserLevelServiceActive', handleOnUserLevelServiceActive)
    Script.register('CSK_UserManagement.OnUserLevelAdminActive', handleOnUserLevelAdminActive)
  end
  Script.releaseObject(handle)
end

--- Function to update user levels
local function updateUserLevel()
  if liveConnectDemo_Model.userManagementModuleAvailable then
    -- Trigger CSK_UserManagement module to provide events regarding user role
    CSK_UserManagement.pageCalled()
  else
    -- If CSK_UserManagement is not active, show everything
    Script.notifyEvent("LiveConnectDemo_OnUserLevelAdminActive", true)
    Script.notifyEvent("LiveConnectDemo_OnUserLevelMaintenanceActive", true)
    Script.notifyEvent("LiveConnectDemo_OnUserLevelServiceActive", true)
    Script.notifyEvent("LiveConnectDemo_OnUserLevelOperatorActive", true)
  end
end

--- Function to send all relevant values to UI on resume
local function handleOnExpiredTmrLiveConnectDemo()

  updateUserLevel()

  Script.notifyEvent("LiveConnectDemo_OnNewStatusPartNumber", liveConnectDemo_Model.partNumber)
  Script.notifyEvent("LiveConnectDemo_OnNewStatusSerialNumber", liveConnectDemo_Model.serialNumber)

  Script.notifyEvent("LiveConnectDemo_OnNewStatusLoadParameterOnReboot", liveConnectDemo_Model.parameterLoadOnReboot)
  Script.notifyEvent("LiveConnectDemo_OnPersistentDataModuleAvailable", liveConnectDemo_Model.persistentModuleAvailable)
  Script.notifyEvent("LiveConnectDemo_OnNewParameterName", liveConnectDemo_Model.parametersName)
end
Timer.register(tmrLiveConnectDemo, "OnExpired", handleOnExpiredTmrLiveConnectDemo)

-- ********************* UI Setting / Submit Functions Start ********************

local function pageCalled()
  updateUserLevel() -- try to hide user specific content asap
  tmrLiveConnectDemo:start()
  return ''
end
Script.serveFunction("CSK_LiveConnectDemo.pageCalled", pageCalled)

local function setPartNumber(partNumber)
  _G.logger:fine(nameOfModule .. ": Preset part number to " .. partNumber)
  liveConnectDemo_Model.partNumber = partNumber
end
Script.serveFunction('CSK_LiveConnectDemo.setPartNumber', setPartNumber)

local function setSerialNumber(serialNumber)
  _G.logger:fine(nameOfModule .. ": Preset serial number to " .. serialNumber)
  liveConnectDemo_Model.serialNumber = serialNumber
end
Script.serveFunction('CSK_LiveConnectDemo.setSerialNumber', setSerialNumber)

local function addMQTTProfileViaUI()
  _G.logger:info(nameOfModule .. ": Add MQTT profile with partNo. " .. liveConnectDemo_Model.partNumber .. " and serialNo. " .. liveConnectDemo_Model.serialNumber)
  liveConnectDemo_Model.addNewMQTTProfile(liveConnectDemo_Model.partNumber, liveConnectDemo_Model.serialNumber)
end
Script.serveFunction('CSK_LiveConnectDemo.addMQTTProfileViaUI', addMQTTProfileViaUI)

local function addHTTPProfileViaUI()
  _G.logger:info(nameOfModule .. ": Add HTTP profile with partNo. " .. liveConnectDemo_Model.partNumber .. " and serialNo. " .. liveConnectDemo_Model.serialNumber)
  liveConnectDemo_Model.addNewHTTPProfile(liveConnectDemo_Model.partNumber, liveConnectDemo_Model.serialNumber)
end
Script.serveFunction('CSK_LiveConnectDemo.addHTTPProfileViaUI', addHTTPProfileViaUI)

-- *****************************************************************
-- Following function can be adapted for CSK_PersistentData module usage
-- *****************************************************************

local function setParameterName(name)
  _G.logger:fine(nameOfModule .. ": Set parameter name: " .. tostring(name))
  liveConnectDemo_Model.parametersName = name
end
Script.serveFunction("CSK_LiveConnectDemo.setParameterName", setParameterName)

local function sendParameters()
  if liveConnectDemo_Model.persistentModuleAvailable then
    CSK_PersistentData.addParameter(liveConnectDemo_Model.helperFuncs.convertTable2Container(liveConnectDemo_Model.parameters), liveConnectDemo_Model.parametersName)
    CSK_PersistentData.setModuleParameterName(nameOfModule, liveConnectDemo_Model.parametersName, liveConnectDemo_Model.parameterLoadOnReboot)
    _G.logger:fine(nameOfModule .. ": Send LiveConnectDemo parameters with name '" .. liveConnectDemo_Model.parametersName .. "' to CSK_PersistentData module.")
    CSK_PersistentData.saveData()
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
end
Script.serveFunction("CSK_LiveConnectDemo.sendParameters", sendParameters)

local function loadParameters()
  if liveConnectDemo_Model.persistentModuleAvailable then
    local data = CSK_PersistentData.getParameter(liveConnectDemo_Model.parametersName)
    if data then
      _G.logger:fine(nameOfModule .. ": Loaded parameters from CSK_PersistentData module.")
      liveConnectDemo_Model.parameters = liveConnectDemo_Model.helperFuncs.convertContainer2Table(data)
      -- If something needs to be configured/activated with new loaded data, place this here:
      -- ...
      -- ...

      CSK_LiveConnectDemo.pageCalled()
    else
      _G.logger:warning(nameOfModule .. ": Loading parameters from CSK_PersistentData module did not work.")
    end
  else
    _G.logger:warning(nameOfModule .. ": CSK_PersistentData module not available.")
  end
end
Script.serveFunction("CSK_LiveConnectDemo.loadParameters", loadParameters)

local function setLoadOnReboot(status)
  liveConnectDemo_Model.parameterLoadOnReboot = status
  _G.logger:fine(nameOfModule .. ": Set new status to load setting on reboot: " .. tostring(status))
end
Script.serveFunction("CSK_LiveConnectDemo.setLoadOnReboot", setLoadOnReboot)

--- Function to react on initial load of persistent parameters
local function handleOnInitialDataLoaded()

  if string.sub(CSK_PersistentData.getVersion(), 1, 1) == '1' then

    _G.logger:warning(nameOfModule .. ': CSK_PersistentData module is too old and will not work. Please update CSK_PersistentData module.')

    liveConnectDemo_Model.persistentModuleAvailable = false
  else

    local parameterName, loadOnReboot = CSK_PersistentData.getModuleParameterName(nameOfModule)

    if parameterName then
      liveConnectDemo_Model.parametersName = parameterName
      liveConnectDemo_Model.parameterLoadOnReboot = loadOnReboot
    end

    if liveConnectDemo_Model.parameterLoadOnReboot then
      loadParameters()
    end
    Script.notifyEvent('LiveConnectDemo_OnDataLoadedOnReboot')
  end
end
Script.register("CSK_PersistentData.OnInitialDataLoaded", handleOnInitialDataLoaded)

-- *************************************************
-- END of functions for CSK_PersistentData module usage
-- *************************************************

return setLiveConnectDemo_Model_Handle

--**************************************************************************
--**********************End Function Scope *********************************
--**************************************************************************

