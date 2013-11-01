-- 整页跳转的scroller

local super	= Scroller
local M		= class( super )

function M:initInternal(params)
	super.initInternal( self, params )

	-- 翻页所需的最小力量
	self._minFlipForce	= 1
	
	-- 转向范围
	-- 分页范围
	self._flipWidth		= 100
	self._flipHeight	= 100
	
	-- 转向力
	-- 在停止touch滑动后，根据转向力决定scroller将移动到何处
	self._flipForceX	= nil
	self._flipForceY	= nil
end

function M:setFlipSize( width, height )
	self._flipWidth = width
	self._flipHeight = height
end

function M:clearFlipFoce()
	self._flipForceX = nil
	self._flipForceY = nil
end

function M:setFlipFoce( x, y )
	self._flipForceX = x
	self._flipForceY = y
end

function M:getFlipForce()
	return self._flipForceX or 0, self._flipForceY or 0
end

function M:hasFlipForce()
	return self._flipForceX ~= nil or self._flipForceY ~= nil
end

-- 计算翻页的目标点
function M:_getFlipTarget()
	local targetX, targetY = 0, 0

	local x, y = self:getPos()
	local w, h = self._flipWidth, self._flipHeight
	local fx, fy = self:getFlipForce()

	local isReset = true

	-- x
	if math.abs( fx ) > self._minFlipForce then
		if fx > 0 then
			-- 向右移动
			targetX = math.floor( ( x + w ) / w ) * w
		else
			-- 向左移动
			targetX = math.floor( x / w ) * w
		end

		isReset = false
	else
		targetX = self:_getResetPosX()
	end

	-- y
	if math.abs( fy ) > self._minFlipForce then
		if fy > 0 then
			-- 向下移动
			targetY = math.floor( ( y + h ) / h ) * h
		else
			-- 向上移动
			targetY = math.floor( y / h ) * h
		end

		isReset = false
	else
		targetY = self:_getResetPosY()
	end

	return targetX, targetY, isReset
end

-- 计算当前位置的返回点
function M:_getResetPosX()
	local x = self:getPos()
	local w = self._flipWidth

	x = math.floor( ( x + x % w ) / w ) * w

	return x, y
end

function M:_getResetPosY()
	local _, y = self:getPos()
	local h = self._flipHeight

	y = math.floor( ( y + y % h ) / h ) * h

	return y
end

function M:setScrollingForce( ... )
	super.setScrollingForce( self, ... )

	local x, y = self:getScrollingForce()

	if x ~= 0 then self._flipForceX = x end
	if y ~= 0 then self._flipForceY = y end
end




function M:updateScroll()
	self:_updateScroll()

	local callback = self.fOnUpdateScrollCallback
	if callback and type( callback ) == "function" then callback( self ) end
end

function M:_updateScroll()
	self._touchMoved = false
	if self:isTouching() then
		return
	end

	if not self:isAnimating() and self:hasFlipForce() then
		local x, y, isReset = self:_getFlipTarget()

		-- 如果滑动范围超过屏幕范围，则设置为reset模式
		if self:isPositionOutOfBounds( x, y ) then isReset = true end

		-- reset模式使用温柔的方式回弹
		local ease = MOAIEaseType.EASE_IN
		if isReset then
			ease = MOAIEaseType.SOFT_EASE_IN
		end

		self:scrollTo( x, y, 0.5, ease )

		self:clearFlipFoce()
	end

	if not self:isScrolling() then
		return
	end

	self:setScrollingForce( 0, 0 )
end

return M