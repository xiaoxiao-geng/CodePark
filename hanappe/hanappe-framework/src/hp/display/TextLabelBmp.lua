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

--pngName: png字体路径
--size:    字体大小
--charCodes: 有哪些字, 如："0123456789abc",要和图片上字符的顺序一样
--trimSpace: 是否裁掉每个字的空白, 默认为false,即按美术框的大小绘制
function M:setBitmapFont(pngName, size, charCodes, trimSpace)
	if trimSpace == nil then trimSpace = false end
    local font = FontManager:request(pngName, size, charCodes, nil, trimSpace)
    super.setFont(self, font)
	self:setTextSize(size)
end

return M