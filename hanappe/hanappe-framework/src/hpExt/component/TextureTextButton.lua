-- import
local table             = require "hp/lang/table"
local class             = require "hp/lang/class"
local Event             = require "hp/event/Event"
local CustomButton     	= require "hpExt/component/CustomButton"

-- class define
local M                 = class( CustomButton )
local super             = CustomButton

function M:setTextureText( fileName )
	local texture = ""
	if not fileName or fileName == "" then
		texture = "empty.png"
	else
		if self.filePathFormat then
			texture = string.format( self.filePathFormat, fileName )
		else
			texture = string.format( "ml/button/%s.png", fileName )
		end
	end

	self:setContentTexture( texture )
end





M.LongButton = class( M )

function M.LongButton:init( params )
	self.filePathFormat = "ml/button/long/%s.png"

	params.themeName = "ButtonLong"
	params.size = { M.LongButton.getSize() }
	M.init( self, params )
end

function M.LongButton.getSize()
	return HP_BUTTON_LONG_W, HP_BUTTON_LONG_H
end

M.ShortButton = class( M )

function M.ShortButton:init( params )
	self.filePathFormat = "ml/button/short/%s.png"

	params.themeName = "ButtonShort"
	params.size = { M.ShortButton.getSize() }
	M.init( self, params )
end

function M.ShortButton.getSize()
	return HP_BUTTON_SHORT_W, HP_BUTTON_SHORT_H
end

return M