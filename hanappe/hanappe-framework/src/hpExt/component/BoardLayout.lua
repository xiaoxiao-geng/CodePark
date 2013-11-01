--[[
	BoardLayout
	将一个Panel划分为5个部分的布局方式：( top, bottom, left, right, center)
	采用读取child:getBoardLayoutMode的方式进行布局
]]--

-- import
local table                 = require "hp/lang/table"
local class                 = require "hp/lang/class"
local BaseLayout            = require "hp/layout/BaseLayout"

-- class
local super                 = BaseLayout
local M                     = class(super)

local function findChildByDirection( children, direction )
	for k, child in pairs( children ) do
		if child.getBoardLayoutDirection and child:getBoardLayoutDirection() == direction then
			return child
		end
	end
	return nil
end

--------------------------------------------------------------------------------
-- 内部変数の初期化処理です.
--------------------------------------------------------------------------------
function M:initInternal(params)
	super.initInternal( self, params )

    self._horizotalGap = 5
    self._verticalGap = 5
    self._paddingTop = 0
    self._paddingBottom = 0
    self._paddingLeft = 0
    self._paddingRight = 0
end

--------------------------------------------------------------------------------
-- 上下左右の余白を設定します.
--------------------------------------------------------------------------------
function M:setPadding(left, top, right, bottom)
    self._paddingLeft = left or self._paddingTop
    self._paddingTop = top or self._paddingTop
    self._paddingRight = right or self._paddingRight
    self._paddingBottom = bottom or self._paddingBottom
end

--------------------------------------------------------------------------------
-- 上下左右の余白を設定します.
--------------------------------------------------------------------------------
function M:getPadding()
    return self._paddingLeft, self._paddingTop, self._paddingRight, self._paddingBottom
end

--------------------------------------------------------------------------------
-- コンポーネントの間隔を設定します.
--------------------------------------------------------------------------------
function M:setGap(horizotalGap, verticalGap)
    self._horizotalGap = horizotalGap
    self._verticalGap = verticalGap
end

--------------------------------------------------------------------------------
-- コンポーネントの間隔を返します..
--------------------------------------------------------------------------------
function M:getGap()
    return self._horizotalGap, self._verticalGap
end

--------------------------------------------------------------------------------
-- 指定した親コンポーネントのレイアウトを更新します.
--------------------------------------------------------------------------------
function M:update( parent )
	super.update( self, parent )

	local children = parent:getChildren()

	-- 提取5个方向的childs
	local top		= findChildByDirection( children, Direction.top )
	local bottom	= findChildByDirection( children, Direction.bottom )
	local left		= findChildByDirection( children, Direction.left )
	local right		= findChildByDirection( children, Direction.right )
	local center	= findChildByDirection( children, Direction.center )

	self:updateLayout( parent, top, bottom, left, right, center )
end

-- 更新布局
function M:updateLayout( parent, top, bottom, left, right, center )
	local paddingLeft, paddingRight = self._paddingLeft, self._paddingRight
	local paddingTop, paddingBottom = self._paddingTop, self._paddingBottom
	local horizotalGap, verticalGap = self._horizotalGap, self._verticalGap

	local parentWidth, parentHeight = parent:getSize()

	-- 计算每个部分坐标
	local topHeight, bottomHeight = paddingTop, paddingBottom
	local leftWidth, rightWidth = paddingLeft, paddingRight

	local showDebug = false
	if showDebug then
		print("BoardLayout.updateLayout")
		print(debug.traceback())
		print("  parentWidth, parentHeight", parentWidth, parentHeight)
		print("  paddingLeft, paddingRight", paddingLeft, paddingRight)
	end

	--[[
			-- 计算思路
			-- 将board分为4个部分：上下左右
			-- 依次将每个部分的尺寸计算出之后，再计算内部控件的尺寸即可
			┌─────────────────────┐    	paddintTop     ┐
			│ ┌─────────────────┐ │		top.height     ├ topHeight
			│ └─────────────────┘ │		verticalGap    ┘
			├─┬──┬─┬───────┬─┬──┬─┤
			│ │  │ │       │ │  │ │     leftWidth = paddingLeft + left.width + horizotalGap
			│ │  │ │       │ │  │ │   	rightHeight = horizotalGap + right.width + paddingRight
			├─┴──┴─┴───────┴─┴──┴─┤		
			│ ┌─────────────────┐ │ 	verticalGap    ┐  		
			│ └─────────────────┘ │ 	bottom.height  ├ bottomHeight
			└─────────────────────┘ 	paddintBottom  ┘
	]]--

	if top then
		local _, h = top:getSize()
		topHeight = paddingTop + h + verticalGap

		top:setPos( paddingLeft, paddingTop )
		top:setSize( parentWidth - paddingLeft - paddingRight, h )

		if showDebug then
			print("  top", paddingLeft, paddingTop, top:getSize() )
		end
	end

	if bottom then
		local _, h = bottom:getSize()
		bottomHeight = verticalGap + h + paddingBottom

		bottom:setPos( paddingLeft, parentHeight - bottomHeight + verticalGap )
		bottom:setSize( parentWidth - paddingLeft - paddingRight, h )

		if showDebug then
			print("  bottom", paddingLeft, parentHeight - bottomHeight + verticalGap, bottom:getSize() )
		end
	end

	if left then
		local w, _ = left:getSize()
		leftWidth = paddingLeft + w + horizotalGap

		left:setPos( paddingLeft, topHeight )
		left:setSize( w, parentHeight - topHeight - bottomHeight )

		if showDebug then
			print("  left", paddingLeft, topHeight, left:getSize() )
		end
	end

	if right then
		local w, _ = right:getSize()
		rightWidth = horizotalGap + w + paddingRight

		right:setPos( parentWidth - rightWidth + horizotalGap, topHeight )
		right:setSize( w, parentHeight - topHeight - bottomHeight )

		if showDebug then
			print("  right", parentWidth - rightWidth + horizotalGap, topHeight, right:getSize() )
		end
	end

	if center then
		center:setPos( leftWidth, topHeight )
		center:setSize( parentWidth - leftWidth - rightWidth, parentHeight - topHeight - bottomHeight )

		if showDebug then
			print("  center", leftWidth, topHeight, center:getSize() )
		end
	end
end

return M