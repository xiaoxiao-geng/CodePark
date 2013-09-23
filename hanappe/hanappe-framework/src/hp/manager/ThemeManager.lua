----------------------------------------------------------------------------------------------------
-- This is a class to manage Theme.
----------------------------------------------------------------------------------------------------

-- import
local Event             = require "hp/event/Event"
local EventDispatcher   = require "hp/event/EventDispatcher"
local Theme             = require "hp/gui/Theme"

-- class define
local M                 = EventDispatcher()
local theme             = Theme

----------------------------------------------------------------
-- Sets the default widget theme to use.
-- @param value Widget theme.
----------------------------------------------------------------
function M:setTheme(value)
    value = type(value) == "string" and dofile(value) or value
    if theme ~= value then
        theme = value
        self:dispatchEvent("themeChanged")
    end
end

----------------------------------------------------------------
-- Returns the current default theme.
-- @return GuiTheme.
----------------------------------------------------------------
function M:getTheme()
    return theme
end

----------------------------------------------------------------
-- Returns the current default theme.
-- @return component theme.
----------------------------------------------------------------
function M:getComponentTheme(name)
    return theme[name]
end

----------------------------------------------------------------
-- Add user skin in to manager
-- 2013-9-23 ultralisk add
----------------------------------------------------------------
function M:addUserSkin( name, skin )
	theme[ name ] = skin
    self:dispatchEvent("themeChanged")
end

----------------------------------------------------------------
-- Add user theme in to manager
-- 2013-9-23 ultralisk add
-- @param doNotCallThemeChanged  不调用themeChanged事件
----------------------------------------------------------------
function M:addUserTheme( userTheme )
	if not userTheme or type( userTheme ) ~= "table" then return end

	for name, skin in pairs( userTheme ) do
		theme[ name ] = skin
	end
    self:dispatchEvent("themeChanged")
end

return M