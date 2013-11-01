--------------------------------------------------------------------------------
-- ListPanel 继承自 Panel
-- 使用内置的Scroller对子控件进行统一管理的面板
--
-- 对所有的data，按照item的模式进行显示
-- item之间采用滚动方式进行控件复用
--
-- ps. 类似于原有的 cBoard
--
--------------------------------------------------------------------------------

--[[
	-- 使用sample：
	local function fCreate( id )
		local button = Button { text = tostring(id), themeName = "BlackButton" }
		return button
	end

	local function fSetData( ui, data )
		print("fSetData", ui, ui.id, data)
		ui:setText( tostring( ui.id ) .. ":" .. tostring( data ) )
	end

	local panel = Panel { layer = layer, pos = { 50, 50 }, size = { 400, 400 }, themeName = "GrayPanel" }

	local listPanel = ListPanel { 
		parent = panel, 
		itemConfig = { 100, 50, 20, 10 }, 		-- width, height, 横向间距, 纵向间距
		itemMode = { 3, 5, "horizon" },			-- 列数, 行数, 模式[ 横向：horizon 纵向（默认）：vertical ]
		panelAlign = { "center", "center" },	-- 在父控件的中的对齐方式
		itemCallback = { fCreate, fSetData }, 	-- 创建方法、设置方法
		}

	local datas = {}
	for i = 1, 80 do
		table.insert( datas, i )
	end

	listPanel:setDatas( datas )
]]--

-- import
local class						= require "hp/lang/class"
local Sprite					= require "hp/display/Sprite"
local Scroller					= require "hp/gui/Scroller"
local Panel						= require "hp/gui/Panel"
local ListPanelItem = class()

-- class
local M							= class( Panel )
local super						= Panel

-- consts
M.ALIGN_CENTER = 1
M.ALIGN_LEFT = 2
M.ALIGN_RIGHT = 3
M.ALIGN_TOP = 4
M.ALIGN_BOTTOM = 5

M.MODE_VERTICAL = 1
M.MODE_HORZION = 2

-- local functions

-- 对齐方式 字符串 -> 常量
local function toAlign( alignStr )
	if type( alignStr ) == "number" then return alignStr end

	if alignStr == "left" then return M.ALIGN_LEFT
	elseif alignStr == "top" then return M.ALIGN_TOP
	elseif alignStr == "right" then return M.ALIGN_RIGHT
	elseif alignStr == "bottom" then return M.ALIGN_BOTTOM
	else return M.ALIGN_CENTER end
end

-- 模式 字符串 -> 常量
local function toMode( modeStr )
	if type( modeStr ) == "number" then return modeStr end

	if modeStr == "horizon" then return M.MODE_HORZION
	else return M.MODE_VERTICAL end
end

function M:initInternal()
	super.initInternal( self )

	self._themeName = "EmptyPanel"

    self.items = {}

    -- 当前的左上角坐标
    self._currCol = 1
    self._currRow = 1

	-- 内部条目的最大数量
	self._itemMaxCols = 1
	self._itemMaxRows = 1

	-- 内部条目的逻辑数量（控件数）
	self._itemCols = 1
	self._itemRows = 1

	-- 内部条目的尺寸
	self._itemWidth = 10
	self._itemHeight = 10

	-- 内部条目之间的间距：水平、垂直
	self._itemHorizonSpace = 0
	self._itemVerticalSpace = 0

	-- 面板在父面板中的对齐方式
	self._panelHorizonAlign = M.ALIGN_CENTER
	self._panelVerticalAlign = M.ALIGN_CENTER

	-- 激活区（条目有效区域，等价于面板的对外尺寸）
	self._activeWidth = 10
	self._activeHeight = 10

	self._mode = M.MODE_VERTICAL

	-- 事件回调
	self._fOnItemCreateCallback = nil
	self._fOnItemSetDataCallback = nil
	

	self:setTouchEnabled( false )
end

function M:initComponent( params )
	if params and params.flipMode == true then
		self._isFlipMode = true
		params.flipMode = nil
	end

	super.initComponent( self, params )
	-- print( " () ()\n( @ @ )\n(  -  )    ListPanel:initComponent" )

	self:_updateActiveAren()
	self:_updatePosInParent()
	self:_createItems()
end

function M:createChildren()
	-- print( "ListPanel:createChildren" )
	super.createChildren( self )

	local scrollerClass = Scroller
	if self._isFlipMode == true then
		scrollerClass = FlipScroller
	end

	-- 滚动面板
	self._scroller = scrollerClass { 
		parent = self, 
		onUpdateScrollCallback = function( scroller ) 
			local parent = scroller:getParent()
			if parent.updateScroll then parent:updateScroll() end
		end,
		}
	self._scroller:addEventListener( Scroller.EVENT_BEGIN_SCROLLING, M.onBeginScrolling )
		
	-- 哨兵值 用于扩充scroller的面板，让面板内的滚动不受阻力影响
	self.sentinel1 = Sprite { parent = self._scroller, size = { 0, 0 }, pos = { 0, 0 } }
	self.sentinel2 = Sprite { parent = self._scroller, size = { 0, 0 }, pos = { 10, 10 } }

	-- self._active_background = Sprite { parent = self._scroller, size = { 10, 10 }, pos = { 0, 0 }, texture = "rect.png", color = { 1, 0.5, 0.5, 1 }, touchEnabled = true }
end

function M:_updateActiveAren()
	-- print( "ListPanel:updateActiveAren" )
	-- print( "  self._itemCols, self._itemRows", self._itemCols, self._itemRows)
	-- print( "  mode", self._mode)

	local col, row = self._itemCols, self._itemRows

	-- 按照mode不同，对col和row有不同的处理
	--     垂直模式：实际的row会少一行，有一行是用于循环的
	--     水平模式：实际的col会少一列，有一列是用于循环的
	if self._mode == M.MODE_HORZION then col = col - 1
	else row = row - 1 end

	-- print( "  col, row", col, row )
	self._activeWidth = col * self._itemWidth + ( col - 1 ) * self._itemHorizonSpace
	self._activeHeight = row * self._itemHeight + ( row - 1 ) * self._itemVerticalSpace
end

-- 更新ListPanel在父面板中的位置
function M:_updatePosInParent()    
    -- 设置scroller的位置
    local parent = self:getParent()
    local pw, ph = parent:getSize()
    -- print( "  parent.size", pw, ph )

    local w, h = math.min( self._activeWidth, pw ), math.min( self._activeHeight, ph )
    -- print( "  active.size", w, h )

	-- 按照对齐方式，基于parent计算出panel的位置
    local x, y = 0, 0
   	local halign, valign = self._panelHorizonAlign, self._panelVerticalAlign

   	if halign == M.ALIGN_LEFT then x = 0
   	elseif halign == M.ALIGN_RIGHT then x = pw - w
   	else x = ( pw - w ) * 0.5 end

   	if valign == M.ALIGN_TOP then y = 0
   	elseif valign == M.ALIGN_BOTTOM then y = ph - h
   	else y = ( ph - h ) * 0.5 end

   	-- print( "  pos", x, y )
   	-- print( "  size", w, h )

   	self:setPos( x, y )
   	self:setSize( w, h )
   	-- self:setClip()
end

-- 创建控件
-- 按照数量创建控件
function M:_createItems()
	-- print("ListPanel:createItems")
	local maxCols, maxRows = self._itemCols, self._itemRows
	local scroller = self._scroller

	local w, h = self._itemWidth, self._itemHeight
	local hspace, vspace = self._itemHorizonSpace, self._itemVerticalSpace

	local items = {}
	for row = 1, maxRows do
		for col = 1, maxCols do
			local id = ( row - 1 ) * maxCols + col
			local item = ListPanelItem( self, scroller, id )

			item.col, item.row = col, row

			local x = ( col - 1 ) * ( w + hspace )
			local y = ( row - 1 ) * ( h + vspace )
			-- print("  ", id, col, row, x, y )
			item:setPos( x, y )

			table.insert( items, item )
		end
	end

	self.items = items
end

-- 条目数量发生改变后更新maxCol和maxRow
-- 调整item的行列最大值，需要根据排版模式而定
-- 垂直模式：固定一个列数，向下扩展行
-- 水平模式：固定一个行数，向右扩展列
function M:_updateItemCount()
	-- print( "updateItemCount" )

	local itemCount = self._itemCount
	local mode = self._mode
	local fixed = self._itemFixed
	local dynamic = math.ceil( itemCount / fixed )

	local maxCols, maxRows = 1, 1

	-- 1. 调整maxCols和maxRows
	if mode == M.MODE_VERTICAL then	maxCols, maxRows = fixed, dynamic
	else maxCols, maxRows = dynamic, fixed end

	self._itemMaxCols, self._itemMaxRows = maxCols, maxRows
	-- print( "  maxCols, maxRows", maxCols, maxRows )
	-- print( "  itemSize", self._itemWidth, self._itemHeight )
	-- print( "  itemSpace", self._itemHorizonSpace, self._itemVerticalSpace )

	-- 2. 调整哨兵sprite的位置
	self.sentinel1:setPos( 0, 0 )
	self.sentinel2:setPos(
		maxCols * self._itemWidth + ( maxCols - 1 ) * self._itemHorizonSpace,
		maxRows * self._itemHeight + ( maxRows - 1 ) * self._itemVerticalSpace
		)

	-- print( "  sentinel1", self.sentinel1:getPos() )
	-- print( "  sentinel2", self.sentinel2:getPos() )
end

function M:updateScroll()
	local scroller = self._scroller

	local x, y = scroller:getPos()
	local w, h = scroller:getSize()
	-- print( "ListPanel:", math.floor(x), math.floor(y), math.floor(w), math.floor(h) )

	-- self._active_background:setSize( w, h )

	self:_trySwapItem()
end

function M:reestPos()
	self._scroller:setPos( 0, 0 )
end


















--------------------------------------------------------------------------------
-- Getters & Setter
--------------------------------------------------------------------------------

function M:setFlipSize( width, height )
	local scroller = self._scroller
	if scroller.setFlipSize then
		scroller:setFlipSize( width, height )
	end
end

function M:setItemConfig( width, height, horizonSpace, verticalSpace )
	self:setItemSize( width, height )
	self:setItemSpace( horizonSpace, verticalSpace )
end

function M:setItemSize( width, height )
	-- print( "ListPanel:setItemSize", width, height )

	self._itemWidth = width
	self._itemHeight = height
end

function M:setItemSpace( horizon, vertical )
	-- print( "ListPanel:seztItemSpace", horizon, vertical )

	self._itemHorizonSpace = horizon
	self._itemVerticalSpace = vertical

	self:updateFlipSize()
end

function M:setPanelAlign( horizon, vertical )
	-- print( "ListPanel:setPanelAlign", horizon, vertical )

	self._panelHorizonAlign = toAlign( horizon )
	self._panelVerticalAlign = toAlign( vertical )

	self:updateFlipSize()
end

function M:setItemCallback( fCreate, fSetData, source )
	-- print( "ListPanel:setItemCallback", fCreate, fSetData, source )

	self._fOnItemCreateCallback = fCreate
	self._fOnItemSetDataCallback = fSetData
	self._fItemCallbackSource = source
end

function M:setParent( parent )
    super.setParent( self, parent )

	-- print( "ListPanel:setParent", parent )
end

-- 设置面板的模式
-- @param cols 		水平方向显示多少个item
-- @param rows 		垂直方向显示多少个item
-- @param mode 		列表模式，垂直 or 水平
--					垂直模式：设置固定的列数，向下扩展更多的行
--					水平模式：设置固定的行数，向右扩展更多的列
function M:setItemMode( cols, rows, mode )
	-- print( "ListPanel:setItemMode", cols, rows, mode )

	local scroller = self._scroller
	mode = toMode( mode )

	self._mode = toMode( mode )
	-- print( "  mode", mode )

	local fixed = 0
 	if mode == M.MODE_VERTICAL then 
		rows = rows + 1
		fixed = cols

		scroller:setHBounceEnabled( false )
		scroller:setVBounceEnabled( true )
	else 
		cols = cols + 1 
		fixed = rows

		scroller:setHBounceEnabled( true )
		scroller:setVBounceEnabled( false )
	end

	self._itemCols = cols
	self._itemRows = rows
	self._itemFixed = fixed

	-- print( "  cols, rows, fixed:", cols, rows, fixed )
	self:updateFlipSize()
end

function M:updateFlipSize()
	if self._isFlipMode ~= true then return end

	local rows, cols = self._itemRows, self._itemCols
	local mode = self._mode

	-- 计算实际显示的 row、col
	if mode == M.MODE_VERTICAL then
		rows = rows - 1
	else
		cols = cols - 1
	end

	local w, h = self._itemWidth, self._itemHeight
	local gapH, gapV = self._itemHorizonSpace, self._itemVerticalSpace

	local flipW = w * cols + gapH * ( cols - 0 )
	local flipH = h * rows + gapV * ( rows - 0 )

	self:setFlipSize( flipW, flipH )
end

-- 设置数据（采用数组的形式）
function M:setDatas( datas )
	-- print( "ListPanel:setDatas", datas, #datas, self )
	self.datas = datas
	self:_setItemCount( #datas )

	local items = self.items

	-- 直接赋值
	for k, item in pairs( items ) do
		local col, row = item.col, item.row
		local data = self:getData( col, row )
		-- print("  set -> col, row, data", col, row, data)
		item:setData( data )
	end

	self._scroller:updateLayout()
	self._scroller:fitEnable()
end

function M:stopAnimation()
	self._scroller:stopAnimation()
end

-- 设置item的数量，用于
function M:_setItemCount( count )
	count = count or 0
	if count < 0 then count = 0 end

	self._itemCount = count

	self:_updateItemCount()
end

-- 通过行列得到数据数组中的data
function M:getData( col, row )
	local index = self:getDataIndex( col, row )
	return self.datas[ index ]
end

-- 通过行列得到数据数组中的index
function M:getDataIndex( col, row )
	-- 按照模式有不同的计算方式
	if self._mode == M.MODE_VERTICAL then
		return col + ( row - 1 ) * self._itemMaxCols
	else
		if self._isFlipMode then
			-- 横向翻页，采用纵向排列，按页分组
			local cols, rows = self._itemCols - 1, self._itemRows
			local page = math.floor( ( col - 1 ) / ( cols ) )

			local col = ( col - 1 ) % cols + 1
			local row = ( row - 1 ) % rows + 1

			return col + ( row - 1 ) * cols + page * cols * rows
		else
			return row + ( col - 1 ) * self._itemMaxRows 
		end
	end
end






--------------------------------------------------------------------------------
-- 触摸事件额外处理部分
--------------------------------------------------------------------------------
function M.onBeginScrolling( e )
	local scroller = e.target
	-- print("onBeginScrolling", scroller)

	local self = scroller:getParent()
	-- print("  self", self)

	-- 遍历所有item，取消按下状态
	local items = self.items
	for k, v in pairs( items ) do
		local widget = v.ui
		if widget and widget.touchCancelHandler then
			widget:touchCancelHandler()
		end
	end
end










--------------------------------------------------------------------------------
-- 控件复用相关代码
-- 使用滚动的方式复用控件
-- 如 ABC -> CAB -> BCA 这样滚动
--------------------------------------------------------------------------------

-- 尝试更新
function M:_trySwapItem()
	local items 				= self.items
	if #items <= 0 then return end

	local scroller 				= self._scroller
	local itemW, itemH 			= self._itemWidth, self._itemHeight
	local maxCols, maxRows		= self._itemMaxCols, self._itemMaxRows
	local viewLeft, viewRight 	= 0, self._activeWidth
	local viewTop, viewBottom 	= 0, self._activeHeight

	local sx, sy 				= scroller:getPos()

	local first 				= items[ 1 ]
	local last 					= items[ #items ]

	local fx, fy = first:getPos()
	fx, fy = fx + sx, fy + sy
	local lx, ly = last:getPos()
	lx, ly = lx + sx, ly + sy

	-- print("  fx, fy, lx, ly", fx, fy, lx, ly)

	-- 如果第一行低于视野范围
	if fy > viewTop and first.row > 1 then
		print( "top" )
		self:_moveTop()

	elseif ly + itemH < viewBottom and last.row < maxRows then 
		print( "bottom" )
		self:_moveBottom()
	end
	
	if fx > viewLeft and first.col > 1 then
		print( "left" )
		self:_moveLeft()

	elseif lx + itemW < viewRight and last.col < maxCols then
		print( "right" )
		self:_moveRight()
	end

end

-- 将队尾的移动到队首
function M:_moveTop()
	self._currRow = self._currRow - 1

	local items 		= self.items
	local itemW, itemH 	= self._itemWidth, self._itemHeight
	local spaceH, spaceV= self._itemHorizonSpace, self._itemVerticalSpace
	local cols, rows 	= self._itemCols, self._itemRows
	local datas 		= self.datas

	local first 		= items[ 1 ]
	local _, firstY 	= first:getPos()
	local firstRow 		= first.row

	local bottomRow = self:_getBottomRow()
	for col = 1, #bottomRow  do
		local item = bottomRow[ col ]

		local x, y = item:getPos()
		item:setPos( x, firstY - itemH - spaceV )
		item.row = firstRow - 1

		table.remove( items, #items - cols + col )
		table.insert( items, col, item )

		item:updateData()
	end
end

function M:_moveBottom()
	self._currRow = self._currRow + 1

	local items 		= self.items
	local itemW, itemH 	= self._itemWidth, self._itemHeight
	local spaceH, spaceV= self._itemHorizonSpace, self._itemVerticalSpace
	local cols, rows 	= self._itemCols, self._itemRows
	local datas 		= self.datas

	local last 			= items[ #items ]
	local _, lastY 		= last:getPos()
	local lastRow 		= last.row

	local topRow = self:_getTopRow()
	for col = 1, #topRow do
		local item = topRow[ col ]

		local x, y = item:getPos()
		item:setPos( x, lastY + itemH + spaceV )
		item.row = lastRow + 1

		table.remove( items, 1 )
		table.insert( items, item )

		item:updateData()
	end
end

function M:_moveLeft()
	self._currCol = self._currCol - 1

	local items 		= self.items
	local itemW, itemH 	= self._itemWidth, self._itemHeight
	local spaceH, spaceV= self._itemHorizonSpace, self._itemVerticalSpace
	local cols, rows 	= self._itemCols, self._itemRows
	local datas 		= self.datas

	local first 		= items[ 1 ]
	local firstX, _ 	= first:getPos()
	local firstCol 		= first.col

	local rightCol = self:_getRightCol()
	for row = 1, #rightCol do
		local item = rightCol[ row ]

		local x, y = item:getPos()
		item:setPos( firstX - itemW - spaceH, y )
		item.col = firstCol - 1

		table.remove( items, row * cols )
		table.insert( items, row * cols - cols + 1, item )

		item:updateData()
	end
end

function M:_moveRight()
	self._currCol = self._currCol + 1

	local items 		= self.items
	local itemW, itemH 	= self._itemWidth, self._itemHeight
	local spaceH, spaceV= self._itemHorizonSpace, self._itemVerticalSpace
	local cols, rows 	= self._itemCols, self._itemRows
	local datas 		= self.datas

	local last 			= items[ #items ]
	local lastX, _ 		= last:getPos()
	local lastCol 		= last.col

	local leftCol = self:_getLeftCol()
	for row = 1, #leftCol do
		local item = leftCol[ row ]

		local x, y = item:getPos()
		item:setPos( lastX + itemW + spaceH, y )
		item.col = lastCol + 1

		table.remove( items, ( row - 1 ) * cols + 1 )
		table.insert( items, row * cols, item )

		item:updateData()
	end
end

function M:_getTopRow()
	local items = self.items
	local cols = self._itemCols

	local arr = {}
	for col = 1, cols do
		arr[ col ] = items[ col ]
	end
	return arr
end

function M:_getBottomRow()
	local items = self.items
	local cols = self._itemCols

	local arr = {}
	for col = 1, cols do
		arr[ col ] = items[ #items - cols + col ]
	end
	return arr
end

function M:_getLeftCol()
	local items = self.items
	local cols, rows = self._itemCols, self._itemRows

	local arr = {}
	for row = 1, rows do
		arr[ row ] = items[ ( row - 1 ) * cols + 1 ]
	end
	return arr
end

function M:_getRightCol()
	local items = self.items
	local cols, rows = self._itemCols, self._itemRows

	local arr = {}
	for row = 1, rows do
		arr[ row ] = items[ row * cols ]
	end
	return arr
end









-- 公共接口

-- 取消item的选中状态
function M:cancelActived()
	local items = self.items
	for k, v in pairs( items ) do
		local widget = v.ui
		if widget and widget.setActived then
			widget:setActived( false )
		end
	end
end

-- 刷新按钮中的内容
function M:refreshButton()
	local items = self.items
	for k, v in pairs( items ) do
		v:updateData()
	end
end





















--------------------------------------------------------------------------------
-- ListPanelItem 用于占位的条目
-- 在没有数据之前，使用占位item
-- 有数据后再进行加载
--------------------------------------------------------------------------------

function ListPanelItem:init( parent, scroller, id )
	self.parent = parent
	self.scroller = scroller

	self.ui = nil

	self.col = 0
	self.row = 0

	self.x = 0
	self.y = 0

	self.id = id
end

function ListPanelItem:updateData()
	local col, row = self.col, self.row
	local parent = self.parent

	local data = parent:getData( col, row )
	self:setData( data )
end

function ListPanelItem:setData( data )
	local ui = self.ui
	local parent = self.parent

	self.data = data

	if data ~= nil then
		-- 1. 没有ui则创建
		if not ui then
			local fCreate = parent._fOnItemCreateCallback
			-- print("fCreate:", fCreate)
			if fCreate and type( fCreate ) == "function" then
				local source = parent._fItemCallbackSource
				if source then
					ui = fCreate( source, self.id )
				else
					ui = fCreate( self.id )
				end

				ui.id = self.id
				ui:setPos( self.x, self.y )
				ui:setSize( parent._itemWidth, parent._itemHeight )
				ui:setParent( self.scroller )

				-- print( "create ui", id, ui )
				-- print( "  pos", ui:getPos() )
				-- print( "  size", ui:getSize() )

				self.ui = ui
			end
		end

		-- 2. 显示
		ui:show()

		-- 3. 赋值
		local fSetData = parent._fOnItemSetDataCallback
		if fSetData and type( fSetData ) == "function" then
			local source = parent._fItemCallbackSource
			if source then
				fSetData( source, ui, data )
			else
				fSetData( ui, data )
			end
		end
	else
		-- data为空，尝试隐藏ui
		if ui then ui:hide() end
	end
end

function ListPanelItem:getPos()
	return self.x, self.y
end

function ListPanelItem:setPos( x, y )
	self.x, self.y = x, y

	local ui = self.ui
	if ui then ui:setPos( x, y ) end
end

return M