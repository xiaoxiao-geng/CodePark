--------------------------------------------------------------------------------
-- cdsc add: TextLabelBmp for bmp font
--------------------------------------------------------------------------------

-- import
local class                     = require("hp/lang/class")
local TextLabel                 = require("hp/display/TextLabel")

-- class
local M                         = class(TextLabel)
local super                     = TextLabel

--------------------------------------------------------------------------------
-- Set the font.
-- @param font font.
--------------------------------------------------------------------------------
function M:setFont(font)
    super.setFont(self, font)

    self:setRGBA( 255, 255, 255, 1 )
    self:setShader( MOAIShaderMgr.getShader ( MOAIShaderMgr.DECK2D_SHADER ) )
end


return M