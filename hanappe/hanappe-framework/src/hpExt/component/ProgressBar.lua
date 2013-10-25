----------------------------------------------------------------
-- 进度条控件
--
-- 改进计划 TODO：
-- 1. 在接近100%的时候，mask会和bar冲突，可以尝试考虑在95%-100%进行alpha渐变
----------------------------------------------------------------

-- import
local table             = require "hp/lang/table"
local class             = require "hp/lang/class"
local Event             = require "hp/event/Event"
local Component        	= require "hp/gui/Component"

-- class define
local super             = Component
local M                 = class( super )

function M:initInternal()
	super.initInternal( self )
	self._themeName = "ProgressBar"

	self._currValue = 0
	self._maxValue = 1

	self._barW, self._barH = 0, 0
	self._barX, self._barY = 0, 0
end

function M:createChildren()
	super.createChildren( self )

	local backgroundClass = self:getStyle( "backgroundSkinClass" )
	if backgroundClass then
		self._background = backgroundClass( self:getStyle( "backgroundSkin" ) )
		self:addChild( self._background )
	end

	print("onCreateChildren", self:getSize())

    local barClass = self:getStyle( "barSkinClass" )
    self._barClass = barClass
	self._barPadding = self:getStyle( "barPadding" ) or { 0, 0, 0, 0 } 
    self._bar = barClass( self:getStyle( "barSkin" ) )
    self._bar:setColor( unpack( self:getStyle( "barColor" ) or { 1, 1, 1, 1 } ) )
    self:addChild( self._bar )

    local maskClass = self:getStyle( "maskSkinClass" )
    if maskClass then
	    self._maskClass = maskClass
	    self._mask = maskClass( self:getStyle( "maskSkin" ) )
	    self._mask:setColor( unpack( self:getStyle( "maskColor" ) or { 1, 1, 1, 1 } ) )
    	self:addChild( self._mask )
	end

    local textStyle = self:getStyle( "textStyle" )
    if textStyle then
    	self._textFormat = self:getStyle( "textFormat" ) or "%d/%d"
		self._text = TextLabel.create { parent = self, align = { "center", "center" }, text = "0/0", style = textStyle }
    end
end

function M:updateDisplay()
	super.updateDisplay( self )

	local w, h = self:getSize()

	if self._background then
		self._background:setSize( w, h )
	end

	local left, top, right, bottom = unpack( self._barPadding )
	local barW, barH = w - left - right, h - top - bottom

	self._barX, self._barY = left, top
	self._barW, self._barH = barW, barH

	self._bar:setSize( barW, barH )
	self._bar:setPos( left, top )
	self:setValue( self._currValue, self._maxValue )

	if self._text then
		local lblH = math.max( 20, h )
		self._text:setPos( 0, math.even( ( h - lblH ) * 0.5 ) )
		self._text:setSize( w, lblH )
	end
end

function M:setValue( curr, max )
	curr = math.floor( curr )
	max = math.floor( max )

	self._currValue = curr
	self._maxValue = max

	if self._mask then
		self:updateMaskMode()
	else
		self:updateFillMode()
	end

	if self._text then
		self._text:setText( string.format( self._textFormat, curr, max ) )
	end
end

-- 使用遮挡模式
function M:updateMaskMode()
	local curr, max = self._currValue, self._maxValue
	local mask = self._mask
	local x, y = self._barX, self._barY
	local w, h = self._barW, self._barH

	local maskW = math.floor( ( 1 - (curr / max ) ) * w )
	if maskW < 0 then maskW = 0
	elseif maskW > w then maskW = w end

	if maskW <= 0 then
		mask:hide()
	else
		mask:show()

		mask:setPos( x + w - maskW, y )
		mask:setSize( maskW, h )
	end
end

-- 使用填充模式 
function M:updateFillMode()
	local curr, max = self._currValue, self._maxValue
	local bar = self._bar
	local x, y = self._barX, self._barY
	local w, h = self._barW, self._barH

	local barW = math.floor( ( curr / max ) * w )
	if barW < 0 then barW = 0
	elseif barW > w then barW = w end

	if barW <= 0 then
		bar:hide()
	else
		bar:show()

		bar:setSize( barW, h )
	end
end

return M