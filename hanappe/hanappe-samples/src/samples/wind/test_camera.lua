module( ..., package.seeall )

local UP = 119
local DOWN = 115
local LEFT = 97
local RIGHT = 100

local sw, sh = Application.screenWidth, Application.screenHeight

function onCreate()
	view = View { scene = scene }

	local w, h = 480, 320
	for i = 1, 6 do
		for j = 1, 8 do
			Sprite { parent = view, texture = "title.png", pos = { ( i - 1 ) * w, ( j - 1 ) * h } }
		end
	end

	sprite = Sprite { parent = view, pos = { 200, 200 }, texture = "bird1.png" }

	cameraSprite = Sprite { parent = view, loc = { 200, 200 }, size = { 10, 10 }, texture = "rect.png" }

	camera = view:getLayer():createCamera()
	-- camera = createCamrea( 10000, -10000, 0, 0, 0 )
	-- view:getLayer():setCamera( camera )
	-- fitter = createFitter( view.viewport, camera, sprite, 1000, 1000 )

	cspeed = 1
	stopCount = 0

	cameraX, cameraY = 0, 0
end


function onKeyDown( e )
	print("keyDown", e.key)

	if e.key == 113 then
		local scl = camera:getScl()
		scl = scl - 0.1
		camera:setScl( scl, scl, 1 )
		print("scl = ", scl)
	elseif e.key == 101 then
		local scl = camera:getScl()
		scl = scl + 0.1
		camera:setScl( scl, scl, 1 )
		print("scl = ", scl)
	end
end

function onKeyUp( e )
	print("keyUp", e.key)
end

local function isDown( key )
	return InputManager:isKeyDown( key )
end

function onEnterFrame()

	local x, y = 0, 0
	local speed = 180 / 1000 * 30

	if isDown( UP ) then
		y = -speed
	elseif isDown( DOWN ) then
		y = speed
	end

	if isDown( LEFT ) then
		x = -speed
	elseif isDown( RIGHT ) then
		x = speed
	end

	if x ~= 0 and y ~= 0 then
		x = x / 1.41
		y = y / 1.41
	end

	local locx, locy = sprite:getLoc()

	sprite:setLoc( locx + x, locy + y )

	updateCamera()
end

local distance = function( x1, y1, x2, y2 )
	local a, b = x2 - x1, y2 - y1
	return math.sqrt( a * a + b * b )
end

function updateCamera()
	local x, y = sprite:getLoc()

	local scl = camera:getScl()

	local cx, cy = x - sw / 2, y - sh / 2
	local w, h = sw * scl, sh * scl

	local bl, bt, br, bb = 0, 0, 2000, 2000

	-- 将镜头限制在屏幕范围内
	if cx < bl then cx = bl
	elseif cx + w > br then cx = br - w end

	if cy < bt then cy = bt
	elseif cy + h > bb then cy = bb - h end

	-- 整理一下思路
	-- 首先计算当前camera的点距离目标点的距离
	-- 使用距离作为speed的依据，让camera向目标靠拢
	local tx, ty = cx, cy

	local x, y = cameraX, cameraY

	local dist = distance( x, y, tx, ty )
	if dist <= 0 then return end
	
	local ox, oy = ( tx - x ) / dist, ( ty - y ) / dist

	-- 分段计算跟随速度
	cspeed = dist / 20
	if dist > 100 then
		cspeed = cspeed + ( ( dist - 100 ) / 12 )
	end
	if dist > 200 then
		cspeed = cspeed + ( ( dist - 200 ) / 5 )
	end

	cspeed = math.max( cspeed, 0.01 )
	print(cspeed, dist)

	if cspeed > dist then
		cameraX, cameraY = tx, ty
	else
		cameraX, cameraY = x + ox * cspeed, y + oy * cspeed
	end

	-- camera:setLoc( cx, cy )
	camera:setLoc( math.floor( cameraX + 0.499 ), math.floor( cameraY + 0.499 ) )
end


function createFitter( viewport, camera, prop, mapw, maph )
	local fitter = MOAICameraFitter2D.new ()
	fitter:setViewport ( viewport )
	fitter:setCamera ( camera )
	fitter:setBounds ( 0, 0, mapw, maph )
	fitter:setMin ( sh )
	fitter:start ()
	local anchor = MOAICameraAnchor2D.new ()
	anchor:setParent(prop)
	fitter:insertAnchor ( anchor )

	return fitter
end

function createCamrea( NearPlane, FarPlane, x, y, z )
	local camera = MOAICamera.new ()
	camera:setOrtho ( true )
	camera:setNearPlane ( NearPlane )
	camera:setFarPlane ( FarPlane )
	camera:setRot ( x, y, z )
	return camera;
end