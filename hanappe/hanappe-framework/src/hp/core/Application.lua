--------------------------------------------------------------------------------
-- Module for the start of the application.<br>
--
-- @class table
-- @name Application
--------------------------------------------------------------------------------

-- import
local Event                 = require "hp/event/Event"
local EventDispatcher       = require "hp/event/EventDispatcher"
local InputManager          = require "hp/manager/InputManager"

-- class
local M                     = EventDispatcher()
local super                 = EventDispatcher

--------------------------------------------------------------------------------
-- Start the application. <br>
-- You can specify the behavior of the entire application by the config.
-- @param config
--------------------------------------------------------------------------------
function M:start(config)

    local title = config.title
    local screenWidth = config.screenWidth or MOAIEnvironment.horizontalResolution
    local screenHeight = config.screenHeight or MOAIEnvironment.verticalResolution 
    local viewScale = config.viewScale or 1
    local viewWidth = screenWidth / viewScale
    local viewHeight = screenHeight / viewScale

    --cdsc add start
    screenWidth   = MOAIEnvironment.horizontalResolution or config.screenWidth
    screenHeight  = MOAIEnvironment.verticalResolution or config.screenHeight

    if MOAIEnvironment["osBrand"] == "iOS" then
        screenWidth = MOAIEnvironment.verticalResolution or config.screenHeight
        screenHeight = MOAIEnvironment.horizontalResolution or config.screenWidth
    end

    viewWidth   = config.screenWidth or MOAIEnvironment.horizontalResolution
    viewHeight  = config.screenHeight or MOAIEnvironment.verticalResolution
    viewScale   = screenWidth / viewWidth
    --cdsc add end

    self.title = title
    self.screenWidth = screenWidth
    self.screenHeight = screenHeight
    self.viewWidth = viewWidth
    self.viewHeight = viewHeight
    self.viewScale = viewScale

    MOAISim.openWindow(title, screenWidth, screenHeight)
    InputManager:initialize()
    
    self:registerSystemEvents() --cdsc add
end


-- cdsc add start
function M:exit(code)
    code = code or 0
    if MOAIApp and MOAIApp.exit then
        MOAIApp.exit()
    else
        os.exit( code )
    end
    return true
end

function M:registerSystemEvents()
    --back button
    if MOAIApp and MOAIApp.BACK_BUTTON_PRESSED then
        MOAIApp.setListener ( MOAIApp.BACK_BUTTON_PRESSED, self.exit )
    end
end
-- cdsc add end

--------------------------------------------------------------------------------
-- Returns whether the mobile execution environment.
-- @return True in the case of mobile.
--------------------------------------------------------------------------------
function M:isMobile()
    local brand = MOAIEnvironment.osBrand
    return brand == 'Android' or brand == 'iOS'
end

--------------------------------------------------------------------------------
-- Returns whether the desktop execution environment.
-- @return True in the case of desktop.
--------------------------------------------------------------------------------
function M:isDesktop()
    return not self:isMobile()
end

--------------------------------------------------------------------------------
-- Returns true if the Landscape mode.
-- @return true if the Landscape mode.
--------------------------------------------------------------------------------
function M:isLandscape()
    local w, h = MOAIGfxDevice.getViewSize()
    return w > h
end

--------------------------------------------------------------------------------
-- Sets the background color.
--------------------------------------------------------------------------------
function M:setClearColor(r, g, b, a)
    MOAIGfxDevice.setClearColor(r, g, b, a)
end

--------------------------------------------------------------------------------
-- Returns the scale of the Viewport to the screen.
-- @return scale of the x-direction, scale of the y-direction,
--------------------------------------------------------------------------------
function M:getViewScale()
    return self.viewScale
end


return M
