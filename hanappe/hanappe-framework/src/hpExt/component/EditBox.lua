----------------------------------------------------------------
-- This class is a extension button to edit text
----------------------------------------------------------------

-- import
local table             = require "hp/lang/table"
local class             = require "hp/lang/class"
local Event             = require "hp/event/Event"
local CustomButton     	= require "hpExt/component/CustomButton"

-- class define
local M                 = class( CustomButton )
local super             = CustomButton

local MODE_CUSTOM	= 1 	-- 自定义输入模式
local MODE_EDIT		= 2 	-- 编辑模式
local MODE_NUMBER	= 3 	-- 数字输入模式

--------------------------------------------------------------------------------
-- Initializes the internal variables.
--------------------------------------------------------------------------------
function M:initInternal()
	super.initInternal( self )

	self._themeName = "EditBoxButton"
	self._mode = MODE_EDIT

	self:addEventListener( CustomButton.EVENT_CLICK, M.onButtonClick )
end

function M:setModeEdit( fEditCheck )
	seld._mode = MODE_EDIT
	self._fEditCheck = fEditCheck
end

function M:setModeNumber( min, max )
	self._mode = MODE_NUMBER
	self._numberMin = min
	self._numberMax = max
end

function M:setModeCustom( fCustomCallback )
	self._mode = MODE_CUSTOM
	self._fCustomCallback = fCustomCallback
end

function M.onButtonClick( e )
	local self = e.target

	local mode = self._mode
	if mode == MODE_EDIT then
		T.mfShowKeyboardEdit( self, self._fEditCheck )

	elseif mode == MODE_NUMBER then
		T.mfShowKeyboardEditNumber( self, self._numberMin, self._numberMax )

	elseif mode == MODE_CUSTOM then
		local srcText = self:getText()
		T.mfShowKeyboardCustom( function( text ) 
				local callback = self._fCustomCallback
				if callback then
					callback( self, text, srcText )
				end
			end )
	end
end

return M