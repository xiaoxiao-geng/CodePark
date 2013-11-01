--------------------------------------------------------------------------------
-- This is a class to draw the texture. <br>
-- Base Classes => DisplayObject, TextureDrawable, Resizable <br>
--------------------------------------------------------------------------------

-- import
local table                     = require "hp/lang/table"
local class                     = require "hp/lang/class"
local DisplayObject             = require "hp/display/DisplayObject"
local TextureDrawable           = require "hp/display/TextureDrawable"
local Resizable                 = require "hp/display/Resizable"

-- class
local M                         = class(DisplayObject, TextureDrawable, Resizable)

--------------------------------------------------------------------------------
-- The constructor.
-- @param params (option)Parameter is set to Object.<br>
--------------------------------------------------------------------------------
function M:init(params)
	-- ul add begin Sprite构造中如果没有设定pos，getPos取出的结果是 -0.5, -0.5。这里给一个默认值
	if params and type( params ) == "table" and not params.pos then
		params.pos = { 0, 0 }
	end
	-- ul add end

    DisplayObject.init(self)

    params = params or {}
    params = type(params) == "string" and {texture = params} or params
    
    local deck = MOAIGfxQuad2D.new()
    deck:setUVRect(0, 0, 1, 1)
    
    self:setDeck(deck)
    self.deck = deck

    self:copyParams(params)
end

return M