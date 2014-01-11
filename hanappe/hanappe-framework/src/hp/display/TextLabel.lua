--------------------------------------------------------------------------------
-- This is a class to draw the text.
-- See MOAITextBox.<br>
-- Base Classes => DisplayObject, Resizable
--------------------------------------------------------------------------------

-- import
local table                     = require("hp/lang/table")
local class                     = require("hp/lang/class")
local DisplayObject             = require("hp/display/DisplayObject")
local Resizable                 = require("hp/display/Resizable")
local FontManager               = require("hp/manager/FontManager")

-- class
local M                         = class(DisplayObject, Resizable)
local MOAITextBoxInterface      = MOAITextBox.getInterfaceTable()
M.MOAI_CLASS                    = MOAITextBox

-- constraints
M.DEFAULT_FONT                  = "fonts/VL-PGothic.ttf"
M.DEFAULT_CHARCODES             = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 .,:;!?()&/-"
M.DEFAULT_TEXT_SIZE             = 24
M.DEFAULT_COLOR                 = {1, 1, 1, 1}

M.HORIZOTAL_ALIGNS = {
    left    = MOAITextBox.LEFT_JUSTIFY,
    center  = MOAITextBox.CENTER_JUSTIFY,
    right   = MOAITextBox.RIGHT_JUSTIFY,
}

M.VERTICAL_ALIGNS = {
    top     = MOAITextBox.LEFT_JUSTIFY,
    center  = MOAITextBox.CENTER_JUSTIFY,
    bottom  = MOAITextBox.RIGHT_JUSTIFY,
}

--- Max width for fit size.
M.MAX_FIT_WIDTH = 10000000

--- Max height for fit size.
M.MAX_FIT_HEIGHT = 10000000

--------------------------------------------------------------------------------
-- The constructor.
-- @param params (option)Parameter is set to Object.<br>
--------------------------------------------------------------------------------
function M:init(params)
    DisplayObject.init(self)

    params = params or {}
    params = type(params) == "string" and {text = params} or params

    self:setFont(M.DEFAULT_FONT)
    self:setTextSize(M.DEFAULT_TEXT_SIZE)
    self:setColor(unpack(M.DEFAULT_COLOR))
    self:copyParams(params)
end

--------------------------------------------------------------------------------
-- Set the text size.
-- @param width
-- @param height
--------------------------------------------------------------------------------
function M:setSize(width, height)
    width = width or self:getWidth()
    height = height or self:getHeight()
    
    local left, top = self:getPos()
    self:setRect(-width / 2, -height / 2, width / 2, height / 2)
    self:setPos(left, top)

    -- ul add begin 自动调用fitHeight
    if self._autoFitHeight and not self._autoFitting then
        self._autoFitting = true
        self:fitHeight()
    end

    if self._autoFitSize and not self._autoFitting then
        self._autoFitting = true
        self:fitSize()
    end
    -- ul add end
end

--------------------------------------------------------------------------------
-- Set the text size.
-- @param points size.
-- @param dpi (deprecated)Resolution.
--------------------------------------------------------------------------------
function M:setTextSize(points, dpi)
    self._textSizePoints = points
    self._textSizeDpi = dpi
    MOAITextBoxInterface.setTextSize(self, points, dpi)
end

--------------------------------------------------------------------------------
-- Returns the text size.
-- @return points, dpi
--------------------------------------------------------------------------------
function M:getTextSize()
    return self._textSizePoints, self._textSizeDpi
end

--------------------------------------------------------------------------------
-- Set the text.
-- @param text text.
--------------------------------------------------------------------------------
function M:setText(text)
    --------------------------------------------------------------------------------
    -- 2013-10-22 ultralisk add begin
    -- 使用tostring转换一次
    --------------------------------------------------------------------------------
    text = tostring( text )
    --------------------------------------------------------------------------------
    -- 2013-10-22 ultralisk add end
    --------------------------------------------------------------------------------

    self:setString(text)

    -- ul add begin 自动调用fitHeight
    if self._autoFitHeight then
        local x, y = self:getPos()
        self._autoFitting = true
        self:fitHeight()
        self:setPos( x, y )

    elseif self._autoFitSize then
        local x, y = self:getPos()
        self._autoFitting = true
        self:fitSize()
        self:setPos( x, y )

    end
    -- ul add end
end

--------------------------------------------------------------------------------
-- Set the font.
-- @param font font.
--------------------------------------------------------------------------------
function M:setFont(font)
    if type(font) == "string" then
        font = FontManager:request(font, self._textSizePoints or M.DEFAULT_TEXT_SIZE, M.DEFAULT_CHARCODES, self._textSizeDpi)
    end
    MOAITextBoxInterface.setFont(self, font)
end

--------------------------------------------------------------------------------
-- Set the Alignments.
--------------------------------------------------------------------------------
function M:setAlign(horizotalAlign, verticalAlign)
    local h, v = M.HORIZOTAL_ALIGNS[horizotalAlign], M.VERTICAL_ALIGNS[verticalAlign]
    self:setAlignment(h, v)
end

--------------------------------------------------------------------------------
-- Sets the fit size.
-- @param lenfth (Option)Length of the text.
--------------------------------------------------------------------------------
function M:fitSize(length)
    self:setRect(0, 0, M.MAX_FIT_WIDTH, M.MAX_FIT_HEIGHT)
    
    length = length or 1000000
    local left, top, right, bottom = self:getStringBounds(1, length)
    --------------------------------------------------------------------------------
    -- 2013-10-12 ultralisk change begin
    -- 当文本为空的时候，getStringBounds会返回nil，这里做下检查
    --------------------------------------------------------------------------------
    local width, height = nil, nil
    if left then
        local horizonPadding = self._fitHorizonPadding or 2
        local verticalPadding = self._fitVerticalPadding or 2

        width, height = right - left + horizonPadding, bottom - top + verticalPadding
        width = width % 2 == 0 and width or width + 1
        height = height % 2 == 0 and height or height + 1
    else
        width, height = 0, 0 
    end
    --------------------------------------------------------------------------------
    -- 2013-10-12 ultralisk change end
    --------------------------------------------------------------------------------

    self:setSize(width, height)
end

--------------------------------------------------------------------------------
-- Sets the fit height.
-- @param lenfth (Option)Length of the text.
--------------------------------------------------------------------------------
function M:fitHeight(length)
    local w, h, d = self:getDims()
    self:setRect(0, 0, w, M.MAX_FIT_HEIGHT)
    
    print("TextLabel.fitHeight", w, h, self )

    length = length or 1000000
    local padding = 2
    local left, top, right, bottom = self:getStringBounds(1, length)

    --------------------------------------------------------------------------------
    -- 2013-10-12 ultralisk change begin
    -- 当文本为空的时候，getStringBounds会返回nil，这里做下检查
    --------------------------------------------------------------------------------

    -- 无节操TODO
    -- fitHeight是使用TextLabel自身计算文字的rect
    -- 但是在计算过程中会改变rect，在未知的条件下，label的坐标会变化
    -- 理想的解决方案是有一个单独的TextBox，使用和label相同的参数计算文字尺寸

    local width, height = 0, 0
    if left then
        local horizonPadding = self._fitHorizonPadding or 2
        local verticalPadding = self._fitVerticalPadding or 2

        width, height = right - left + horizonPadding, bottom - top + verticalPadding
        width = width % 2 == 0 and width or width + 1
        height = height % 2 == 0 and height or height + 1
    end
    --------------------------------------------------------------------------------
    -- 2013-10-12 ultralisk change end
    --------------------------------------------------------------------------------

    print("  height ->", height)
    self:setHeight(height)

    -- ul add begin
    self._autoFitting = nil
    -- ul add end
end

-- ul add begin

-- 设置自动调用fitHeight
function M:setAutoFitHeight( value )
    self._autoFitHeight = value
end

-- 设置自动调用fitSize
function M:setAutoFitSize( value )
    self._autoFitSize = value
end

-- includeLayout相关内容

function M:setIncludeLayout( value )
    self._includeLayout = value

    local parent = self:getParent()
    if parent.invalidateLayout then
        parent:invalidateLayout()
    end
end

function M:isIncludeLayout()
    return self._includeLayout == nil or self._includeLayout == true
end

-- 设置format文字
function M:setFormatText( format, ... )
    local args = { ... }
    for i = 1, #args do
        args[ i ] = tostring( args[ i ] )
    end
    self:setText( string.format( format, unpack( args ) ) )
end

-- 设置fit运算时的辅助值
function M:setFitPadding( horizon, vertical )
    self._fitHorizonPadding = horizon
    self._fitVerticalPadding = vertical
end

-- ul add end

return M