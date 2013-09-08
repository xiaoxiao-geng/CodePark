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

local lastUpdateTime = nil
function onEnterFrame()
	if not lastUpdateTime then lastUpdateTime = os.clock() end

	updateScroll( os.clock() - lastUpdateTime )

	lastUpdateTime = os.clock()
end

local downX, downY = 0, 0
local downPanelX, downPanelY = 0, 0
local isDown = false
local gridW, gridH = 480, 320
local directionX, directionY

local min, max = -320 * 5 + Application.screenHeight, 0

local points = {}

function onTouchDown( e )
	stopAction()

	points = {}

	downX, downY = e.x, e.y
	downPanelX, downPanelY = panel:getPos()
	isDown = true
end

function onTouchMove( e )
	if not isDown then return end

	while #points >=5 do table.remove( points, #points ) end
	table.insert( points, 1, { e.x, e.y, os.clock() } )

	move( e.x, e.y )
end

function onTouchUp( e )
	if not isDown then return end
	
	move( e.x, e.y )
	isDown = false

	doUpEvent()
end

function move( x, y )
	stopAction()

	-- fixed x
	local offsetX = 0 --x - downX
	local offsetY = y - downY

	panel:setPos( downPanelX + offsetX, downPanelY + offsetY )

	print("move", panel:getPos())
end

function doUpEvent()
	print("doUpEvent")
	print("  points:")
	-- 读取points


	local dragSpeed = getDragSpeed()
	print("  dragSpeed:", dragSpeed)

	movingSpeed = dragSpeed
	dampSpeed = -dragSpeed
	isMoving = true

	-- print("doUpEvent")
	-- print("  pos:", panel:getPos())
	-- print("  loc:", panel:getLoc())
	-- print("  max, min:", max, min)

	-- local x, y = panel:getPos()
	-- local w, h = panel:getSize()

	-- local targetX, targetY = x, y

	-- -- 边界值
	-- if y < min then
	-- 	targetY = min
	-- elseif y > max then
	-- 	targetY = max
	-- else

	-- 	-- 中心对齐
	-- 	--[[
	-- 		思路
	-- 		按照移动方向，按照移动方向判断向哪个方向回弹
	-- 	]]--

	-- 	local gridOffset = -y % gridH
	-- 	print("  gridOffset:", gridOffset)
	-- 	if gridOffset < gridH * 0.1 then
	-- 		--向上回弹
	-- 		targetY = y + gridOffset
	-- 	else
	-- 		targetY = y + gridOffset - gridH
	-- 	end
	-- end

	-- playAction( targetX, targetY, 0.3 )
end

function backPos()
	local x, y = panel:getPos()
	local w, h = panel:getSize()

	local targetX, targetY = x, y

	-- 边界值
	if y < min then
		targetY = min
	elseif y > max then
		targetY = max
	end

	if x ~= targetX or y ~= targetY then
		playAction( targetX, targetY, 0.3 )
	end
end

function playAction( x, y, ... )
	stopAction()
	action = panel:seekLoc( x, y, 0, ... )
end

function stopAction()
	isMoving = false

	if action then
		action:stop()
		action = nil
	end
end


--[[
	从Demo中总结滑动相关的要点
	1. 直接移动
		这个没什么好说的，直接按照移动量1:1更改panel坐标即可

	2. 惯性移动
		需要一个“脱手速度”的概念，按照这个速度向列表方向进行减速运动

	3. 边界回弹
		回弹是个很有意思的设定，只是单纯的松开手指后的回弹很简单，直接向目标seek即可
		但是在配合惯性移动的情况下，回弹是一个非常强烈的减速效果
		这点需要特别注意

	4. grid对齐
		grid对齐的移动方式和惯性移动不大一样，需要轻微的动作，进行翻页操作
]]--

local maxDragSpeed = 5000
function getDragSpeed()
	local dragSpeed = 0
	if #points > 1 then
		local lastY, lastClock, offset, time = nil, nil, 0, 0
		for k, v in pairs( points ) do
			local x, y, clock = unpack( v )

			-- 判断是否有转折
			if lastY then
				local newOffset = lastY - y
				if offset > 0 and newOffset < 0 then break
				elseif offset < 0 and newOffset > 0 then break end

				offset = offset + newOffset
				time = time + ( lastClock - clock )
			end

			lastY = y
			lastClock = clock
		end
		if offset and time then dragSpeed = offset / time end
	end

	if dragSpeed < -maxDragSpeed then dragSpeed = -maxDragSpeed
	elseif dragSpeed > maxDragSpeed then dragSpeed = maxDragSpeed end

	return dragSpeed
end

function getBoundDumpRate()
	-- 按照超出边界的部分计算阻力惩罚值
	local rate = 1

	local x, y = panel:getPos()
	if y < min then
		rate = math.abs( min - y ) / 10
	elseif y > max then
		rate = math.abs( y - max ) / 10
	end

	if rate < 1 then rate = 1 end

	return rate
end




function updateScroll( time )
	if not time or time <= 0 then return end
	if not isMoving then return end
	if not movingSpeed or movingSpeed == 0 then return end

	-- local damp = -3 * movingSpeed
	local dump = dampSpeed * time * getBoundDumpRate()

	if math.abs( movingSpeed ) < math.abs( dump ) then 
		movingSpeed = 0
		isMoving = false
		backPos()
		return
	end

	movingSpeed = movingSpeed + dampSpeed * time
	print( "updateScroll", time, movingSpeed )

	-- 匀速移动不减速
	local x, y = panel:getPos()
	y = y + movingSpeed * time
	panel:setPos( x, y )
end