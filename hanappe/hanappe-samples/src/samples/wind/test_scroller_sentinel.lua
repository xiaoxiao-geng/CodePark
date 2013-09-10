module( ..., package.seeall )

function onCreate( params )
	layer = Layer { scene = scene, touchEnabled = true }

	panel = Panel { layer = layer, size = { 500, 500 }, pos = { 50, 50 } }

	scroller = Scroller {
		parent = panel,
		hBounceEnabled = false,
	}

	space = 0
	itemH = 50
	cols = 2
	rows = 11
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

	for row = 0, rows - 1 do
		for col = 0, col - 1 do
			local x, y = 10, row * 50
			local id = row + 1
			local item = Panel { parent = scroller, size = { 100, 50 }, pos = { x, y }, color = { col * ( 1 / 10 ), row * ( 1 / 10 ), 1, 1 } }
			local label = TextLabel { parent = item, pos = { 20, 10 }, size = { 100, 50 }, text = tostring(id), textSize = 16 }

			item.id = id
			item.row = id

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
	local last = items[ #items ]

	last.row = first.row - 1
	local x, y = first:getPos()
	last:setPos( x, y - itemH )

	table.remove( items, #items )
	table.insert( items, 1, last )
end

function moveBottom()
	row = row + 1

	local first = items[ 1 ]
	local last = items[ #items ]

	first.row = last.row + 1
	local x, y = last:getPos()
	first:setPos( x, y + itemH )

	table.remove( items, 1 )
	table.insert( items, first )
end