-- import
local class						= require "hp/lang/class"
local Component					= require "hp/gui/Component"
local VBoxLayout				= require "hp/layout/VBoxLayout"

-- class
local M							= class( Component )
local super						= Component

function M:initComponent( params )
	-- 预处理Layout的params
	local layoutParams = {}
	layoutParams.padding = params.padding or { 0, 0, 0, 0 }
	layoutParams.spacing = params.spacing or { 0, 0 }
	layoutParams.align = params.align or { "left", "top" }
	params.layout = VBoxLayout( layoutParams )

	params.padding = nil
	params.spacing = nil
	params.align = nil


	super.initComponent( self, params )
end

function M:setAlign( ... )
	if self._layout then
		self._layout:setAlign( ... )
	end
end

return M