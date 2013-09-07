module( ..., package.seeall )

function onCreate( params )
	layer = Layer { scene = scene, touchEnabled = true }

	-- 测试 clip
	sprite = Sprite { texture = "title.png", pos = { 100, 100 } }
	local w, h = sprite:getSize()
	sprite:dispose()

	panel = Group { layer = layer, size = { w, h * 5 }, pos = { 200, 0 },
			touchDown = onTouchDown,
			touchMove = onTouchMove,
			touchUp = onTouchUp,
		}

	for i = 1, 5 do
		local sprite = Sprite { layer = layer, texture = "title.png", pos = { 0, h * ( i - 1 ) } }
		sprite:setParent( panel )

		sprite:setColor( i * 0.2, i * 0.2, i * 0.2, 1 )
	end
end

local downX, downY = 0, 0
local downPanelX, downPanelY = 0, 0
local isDown = false

local min, max = -320 * 5 + Application.screenHeight, 0

function onTouchDown( e )
	downX, downY = e.x, e.y
	downPanelX, downPanelY = panel:getPos()
	isDown = true
end

function onTouchMove( e )
	if not isDown then return end
	move( e.x, e.y )
end

function onTouchUp( e )
	if not isDown then return end
	move( e.x, e.y )
	isDown = false

	doUpEvent()
end

function move( x, y )
	-- fixed x
	local offsetX = 0 --x - downX
	local offsetY = y - downY

	panel:setPos( downPanelX + offsetX, downPanelY + offsetY )

	print("move", panel:getPos())
end

function doUpEvent()
	print("doUpEvent")
	print("  pos:", panel:getPos())
	print("  loc:", panel:getLoc())
	print("  max, min:", max, min)

	local x, y = panel:getPos()
	local w, h = panel:getSize()

	-- 只处理y
	if y < min then
		panel:seekLoc( x, min, 0, 0.3 )
	elseif y > max then
		panel:seekLoc( x, max, 0, 0.3 )
	end
end

