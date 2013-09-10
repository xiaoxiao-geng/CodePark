module( ..., package.seeall )

function onCreate( params )
	layer = Layer { scene = scene, touchEnabled = true }

	panel = Panel { layer = layer, size = { 500, 500 }, pos = { 50, 50 } }

	scroller = Scroller {
		parent = panel,
		hBounceEnabled = false,
	}

	space = 0
	itemW, itemH = 100, 50
	rows, cols = 11, 5
	row = 1

	maxRows = 20

	viewHeight = space * ( rows - 1 + 1 ) + itemH * ( rows - 1 )
	viewTop = 0
	viewBottom = viewHeight

	items = {}

	rect = MOAIScissorRect.new()
	rect:setRect( 62, 58, 538, 534 )

	sentinel1 = Sprite { parent = scroller, size = { 0, 0 }, pos = { 0, 0 } }
	sentinel2 = Sprite { parent = scroller, size = { 0, 0 }, pos = { 300, 1000 } }

	local id = 0
	for row = 0, rows - 1 do
		for col = 0, cols - 1 do
			local x, y = col * itemW, row * itemH
			id = id + 1
			local item = Panel { parent = scroller, size = { itemW, itemH }, pos = { x, y }, color = { col * ( 1 / 10 ), row * ( 1 / 10 ), 1, 1 } }
			local label = TextLabel { parent = item, pos = { 20, 10 }, size = { 100, 50 }, text = tostring(id), textSize = 16 }

			item.id = id
			item.row = row + 1

			item._background:setScissorRect( rect ) 
			label:setScissorRect( rect ) 

			table.insert( items, item )
		end
	end
end

function onEnterFrame()
	local x, y = scroller:getPos()
	local w, h = scroller:getSize()
	print( "scroller:", row, math.floor(x), math.floor(y), w, h )

	trySwapItem()
end

-- 尝试更新
function trySwapItem()
	local sx, sy = scroller:getPos()

	local first = items[ 1 ]
	local last = items[ #items ]

	local _, fy = first:getPos()
	fy = fy + sy
	local _, ly = last:getPos()
	ly = ly + sy

	-- 如果第一行低于视野范围
	if fy > viewTop and first.row > 1 then
		print( "top" )
		moveTop()

	elseif ly + itemH < viewBottom and last.row < maxRows then 
		print( "bottom" )
		moveBottom()
	end

end

-- 将队尾的移动到队首
function moveTop()
	row = row - 1

	local first = items[ 1 ]
	local _, firstY = first:getPos()
	local firstRow = first.row

	local lastRow = getLastRow()
	for col = 1, #lastRow  do
		local item = lastRow[ col ]

		local x, y = item:getPos()
		item:setPos( x, firstY - itemH )
		item.row = firstRow - 1

		table.remove( items, #items - cols + col )
		table.insert( items, col, item )
	end
end

function moveBottom()
	row = row + 1

	local last = items[ #items ]
	local _, lastY = last:getPos()
	local lastRow = last.row

	local firstRow = getFirstRow()
	for col = 1, #firstRow do
		local item = firstRow[ col ]

		local x, y = item:getPos()
		item:setPos( x, lastY + itemH )
		item.row = lastRow + 1

		table.remove( items, 1 )
		table.insert( items, item )
	end
end

function getFirstRow()
	local arr = {}
	for col = 1, cols do
		arr[ col ] = items[ col ]
	end
	return arr
end

function getLastRow()
	local arr = {}
	for col = 1, cols do
		arr[ col ] = items[ #items - cols + col ]
	end
	return arr
end