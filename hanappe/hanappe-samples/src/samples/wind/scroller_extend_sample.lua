module( ..., package.seeall )

function onCreate( params ) 
	layer = Layer { scene = scene, touchEnabled = true }

	panel = Panel { layer = layer, size = { 500, 500 }, pos = { 50, 50 } }

	scroller = Scroller {
		parent = panel,
		hBounceEnabled = false,
	}

	items = {}

	rect = MOAIScissorRect.new()
	rect:setRect( 62, 58, 538, 534 )

	for row = 0, 10 do
		local col = 0
		local x, y = 10, row * 50
		local item = Panel { parent = scroller, size = { 100, 50 }, pos = { x, y }, color = { col * ( 1 / 10 ), row * ( 1 / 10 ), 1, 1 } }

		local label = TextLabel { parent = item, pos = { 20, 10 }, size = { 100, 50 }, text = 0 .. ", " .. row, textSize = 16 }

		item._background:setScissorRect( rect ) 
		label:setScissorRect( rect ) 

		table.insert( items, item )
	end

	-- Animation( items, 60 ):seekLoc( 0, 2000, 0 ):play()
end

local r = 0
function onEnterFrame()
	-- r = r + 1
	-- if r > 10 then r = 0
	-- else return end



	local x, y = scroller:getPos()
	local w, h = scroller:getSize()
	print( "scroller:", math.floor(x), math.floor(y), w, h )

	local first = items[1]
	local last = items[ #items ]

	local fx, fy = first:getFullPos()
	local lx, ly = last:getFullPos()
	print( "  first = ", math.floor(fx), math.floor(fy) )
	print( "  last = ", math.floor(lx), math.floor(ly) )

	if fy < 50 then
		print( " () ()\n( @ @ )\n(  -  )    top")
		moveTopToBottom()
	elseif ly < 500 then
		print( " () ()\n( @ @ )\n(  -  )    bottom")
		moveBottomToTop()
	end
end

function onKeyDown()
	print("onKeyDown")

	addBox( 0, #boxs )
end

function moveTopToBottom()
	local first = items[1]
	local last = items[ #items ]

	local x, y = last:getPos()
	y = y + 50
	first:setPos( x, y )

	table.remove( items, 1 )
	table.insert( items, first )
	
	scroller:ajustScrollSize()
end

function moveBottomToTop()
	local first = items[1]
	local last = items[ #items ]

	local x, y = first:getPos()
	y = y - 50
	last:setPos( x, y )

	table.remove( items, #items )
	table.insert( items, 1, last )
	
	scroller:ajustScrollSize()
end

function addBox( col, row )
	-- local x, y = col * 50 + 100, row * 50
	-- local box = Panel { 
	-- 	parent = scroller, 
	-- 	size = { 50, 50 }, 
	-- 	pos = { x, y }, 
	-- 	color = { col * ( 1 / maxCol ), row * ( 1 / maxRow ), 1, 1 } }

	-- local label = TextLabel { parent = box, pos = { 10, 10 }, size = { 50, 50 }, text = col .. ", " .. row, textSize = 16 }


	-- label:setScissorRect( rect )
	-- box._background:setScissorRect( rect )

	-- box.col, box.row = col, row
	-- table.insert( boxs, box )
end