local Tools = {}

Tools._version = 0.1

function Tools.getVersion()
	return Tools._version
end

--- 将数字限定在范围内
function Tools.limitNumber(n, min, max)
	if n < min then return min end
	if n > max then return max end
	return n
end

function Tools.findNodeByName(root, name)
	if root:getName() == name then
		return root
	end

	local children = root:getChildren()

	local node
	for _, child in pairs(children) do
		node = Tools.findNodeByName(child, name)

		if node then return node end
	end

	return nil
end

function Tools.isAllParentVisible(node)
	local o = node
	local ret = false

	while true do
		if not o then return ret end

		if type(o.isVisible) ~= "function" then return false end

		ret = o:isVisible()
		if not ret then return false end

		if type(o.getParent) ~= "function" then return true end

		o = o:getParent()
	end

	return ret
end

--- 注册点击事件
-- @param node 被注册的节点
-- @param handler 事件处理回调
-- @param bNotSwallTouches 不拦截事件（默认拦截）
local TOUCH_ID = 0
function Tools.registerTouchHandler(node, handler, bNotSwallTouches)
	if not node then return end
	if type(handler) ~= "function" then return end

	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(bNotSwallTouches ~= true)

	local onTouchBegan = function(e)
		if e:getId() ~= TOUCH_ID then return false end

		e.listener = listener
		e.target = node
		if Tools.isWorldLocInNode(node, e:getLocation()) and Tools.isAllParentVisible(node) then
			e.name = "began"
			handler(e)
			return true
		end
		
		return false
	end

	local onTouchMoved = function(e)
		e.listener = listener
		e.target = node

		e.name = "moved"
		handler(e)
	end

	local onTouchEnded = function(e)
		e.listener = listener
		e.target = node

		e.name = "ended"
		handler(e)
	end

	local onTouchCancelled = function(e)
		e.listener = listener
		e.target = node

		e.name = "cancelled"
		handler(e)
	end

	listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN )
	listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED )
	listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED )
	listener:registerScriptHandler(onTouchCancelled, cc.Handler.EVENT_TOUCH_CANCELLED )

	local eventDispatcher = node:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, node)
end

--- 注册拖动事件
function Tools.registerDragHandler(node, dragHandler, rect)
	if not dragHandler then return end

	local touchHandler = function(e)
		if e.name == "began" then
			e.listener:setSwallowTouches(false)
			e.listener.__bDragBegan = nil
			dragHandler(e)

		elseif e.name == "moved" then
			local bInRect = rect and cc.rectContainsPoint(rect, e:getLocation())
			e.listener:setSwallowTouches(not bInRect)

			dragHandler(e)

			if not e.listener.__bDragBegan and not bInRect then
				e.listener.__bDragBegan = true

				local newE = clone(e)
				newE.name = "dragBegan"
				dragHandler(newE)
			end

			if e.listener.__bDragBegan then
				local newE = clone(e)
				newE.name = "dragMoved"
				dragHandler(newE)
			end

		elseif e.name == "ended" or e.name == "cancelled" then
			-- up相关的事件不能拦截
			e.listener:setSwallowTouches(false)
			dragHandler(e)
		end
	end

	ul.Tools.registerTouchHandler(node, touchHandler, true)
end

function Tools.isWorldLocInNode(node, worldLocation)
    local locationInMode = node:convertToNodeSpace(worldLocation)

	local size = node:getContentSize()
	local rect = cc.rect(0, 0, size.width, size.height)

	return cc.rectContainsPoint(rect, locationInMode)
end

--- 创建调试用的menu
-- @param conf {{text, callback}, {text, callback} ...}
function Tools.createDebugMenu(conf)
	local menu = cc.Menu:create()

	for i, v in pairs(conf) do
		local text, callback = unpack(v)
		cc.MenuItemLabel:create(cc.Label:createWithTTF(text, "fonts/arial.ttf", 24))
			:addTo(menu)
			:move(0, (i - 1) * -50)
			:registerScriptTapHandler(callback)
	end

	return menu
end

--- 缩放grildData
function Tools.scaleGridData(srcData, scaleX, scaleY)
	scaleY = scaleY or scaleX

	local dstData = {}
	local rows = #srcData
	local cols = #srcData[1]

	local dstRows = math.floor(rows * scaleY)
	local dstCols = math.floor(cols * scaleX)

	local dstRow, srcRow
	for y = 1, dstRows do
		dstRow = {}
		dstData[y] = dstRow

		srcRow = srcData[math.floor(y / scaleY)]

		for x = 1, dstCols do
			dstRow[x] = srcRow[math.floor(x / scaleX)]
		end
	end

	return dstData
end

--- 合并两个gridData
-- @srcData 源data，被覆盖在底部的
-- @dstData 目标data，替换srcData中的值
-- @offsetX dstData的x偏移值
-- @offsetY dstData的y偏移值
function Tools.mergeGridData(srcData, dstData, offsetX, offsetY)
	-- print("mergeGridData", #srcData, #srcData[1], #dstData, #dstData[1], offsetX, offsetY)
	-- 根据offset计算新的grid的范围
	local srcRows = #srcData
	local srcCols = #srcData[1]

	local dstRows = #dstData
	local dstCols = #dstData[1]

	local srcOffsetX, srcOffsetY = 0, 0
	local dstOffsetX, dstOffsetY = offsetX, offsetY

	if offsetX < 0 then 
		srcOffsetX = -offsetX 
		dstOffsetX = 0
	end

	if offsetY < 0 then 
		srcOffsetY = -offsetY 
		dstOffsetY = 0
	end

	local newRows = math.max(srcRows + srcOffsetY, dstRows + dstOffsetY)
	local newCols = math.max(srcCols + srcOffsetX, dstCols + dstOffsetX)

	local row

	-- 创建newData
	local newData = {}
	for y = 1, newRows do
		local row = {}
		newData[y] = row

		for x = 1, newCols do
			row[x] = 0
		end
	end

	-- 采用src填充newData
	for y = 1, #srcData do
		row = srcData[y]
		for x = 1, #row do
			newData[y + srcOffsetY][x + srcOffsetX] = row[x]
		end
	end

	-- 将dst中非0的数据覆盖到newData中
	for y = 1, #dstData do
		row = dstData[y]
		for x = 1, #row do
			if row[x] ~= 0 then
				newData[y + dstOffsetY][x + dstOffsetX] = row[x]
			end
		end
	end 

	return newData
end

function Tools.resizeGridData(srcData, dstCols, dstRows, offsetX, offsetY)
	-- print("resizeGridData", dstCols, dstRows, offsetX, offsetY)
	-- print("srcData")
	-- for i = #srcData, 1, -1 do
	-- 	print(table.concat(srcData[i]))
	-- end
	local srcRows = #srcData
	local srcCols = #srcData[1]

	-- offsetX = Tools.limitNumber(math.floor(offsetX), 0, dstCols - colCols)
	-- offsetY = Tools.limitNumber(math.floor(offsetY), 0, dstRows - colRows)

	local dstData = {}
	for y = 1, dstRows do
		local row = {}
		dstData[y] = row

		for x = 1, dstCols do
			row[x] = 0
		end
	end

	-- print("dstData")
	-- for i = #dstData, 1, -1 do
	-- 	print(table.concat(dstData[i]))
	-- end

	for y = 1, srcRows do
		local srcRow = srcData[y]
		local dstRow = dstData[y + offsetY]

		for x = 1, srcCols do
			dstRow[x + offsetX] = srcRow[x]
		end
	end

	-- print("dstData")
	-- for i = #dstData, 1, -1 do
	-- 	print(table.concat(dstData[i]))
	-- end

	return dstData
end

function Tools.loadGridData(fileName)
	local text = cc.FileUtils:getInstance():getStringFromFile(fileName)
	if text == "" then return nil end

	local lines = string.split(text, "\n")

	local gridData = {}
	local row
	for y, line in pairs(lines) do
		row = {}
		gridData[y] = row

		for x = 1, string.len(line) do
			row[x] = tonumber(string.sub(line, x, x))
		end
	end

	return gridData
end

--- 保存网格数据
-- 采用io.open的方式打开文件，不能保证多平台的通用性
function Tools.saveGridData(fileName, gridData)
	local buffer = {}

	local row
	for y = 1, #gridData do
		row = gridData[y]
		for x = 1, #row do
			buffer[#buffer + 1] = row[x]
		end
		buffer[#buffer + 1] = "\n"
	end

	table.remove(buffer, #buffer)

	local text = table.concat(buffer)
	local file = io.open(fileName, "w")
	if file then
		file:write(text)
		file:close()
	end
end

function Tools.loadCreamDatas(fileName)
	local text = cc.FileUtils:getInstance():getStringFromFile(fileName)
	if text == "" then return nil end

	local lines = string.split(text, "\n")
	local creamDatas = {}

	local idx = 0

	for i = 1, 4 do
		local data = {}
		local line = lines[i] or ""
		-- print("line", i, line)

		for _, v in pairs(string.split(line, "|")) do
			local fields = string.split(v, ",")
			if #fields >= 2 then
				idx = idx + 1
				table.insert(data, {
					tonumber(fields[1]),
					tonumber(fields[2]),
					tonumber(fields[3] or 1),
					tonumber(fields[4] or 1),
					tonumber(fields[5] or 0),
					tonumber(fields[6] or 0),
					idx,
					i,
					})
			end
		end

		creamDatas[i] = data
	end

	return creamDatas
end

function Tools.loadCreamDatasWithIdx(fileName)
	local creamDatas = Tools.loadCreamDatas(fileName)
	
	local arr = {}
	for level, v in pairs(creamDatas) do
		for _, vv in pairs(v) do
			local idx = vv[7]
			arr[idx] = vv
		end
	end

	return arr
end

function Tools.saveCreamDatas(fileName, creamDatas)
	-- 格式为 
	-- 这里需要考虑顶部和底部的裱花是不同的，需要采用一个id进行区分
	--[[
		第一行为topBack的cream
		第二行为topFront的cream
		第三行为bottom的cream
		第二行为bottom的cream

		x,y|x,y|x,y...
		x,y|x,y|x,y...
		x,y|x,y|x,y...
	]]

	-- 排序
	local fSort = function(a, b)
		-- if a[2] == b[2] then
		-- 	return a[1] <= b[1]
		-- else
			return a[2] < b[2]
		-- end
	end
	for _, data in pairs(creamDatas) do
		table.sort(data, fSort)
	end

	dump(creamDatas)

	local buffer = {}
	for i = 1, 4 do
		local data = creamDatas[i] or {}
		for _, v in pairs(data) do
			for _, vv in pairs(v) do
				buffer[#buffer + 1] = vv
				buffer[#buffer + 1] = ","
			end
			if #v > 0 then table.remove(buffer, #buffer) end

			buffer[#buffer + 1] = "|"
		end
		-- 去除行末尾的"|"
		if #data > 0 then table.remove(buffer, #buffer) end
		buffer[#buffer + 1] = "\n"
	end
	-- 去除最后一行的换行符
	table.remove(buffer, #buffer)

	local text = table.concat(buffer)
	local file = io.open(fileName, "w")
	if file then
		file:write(text)
		file:close()
	end
end

function Tools.clipGridData(srcData, stencilData)
	-- 必须确保尺寸一样
	if #srcData ~= #stencilData or #srcData[1] ~= #stencilData[1] then return end

	srcData = clone(srcData)

	for y = 1, #srcData do
		local srcRow = srcData[y]
		local stencilRow = stencilData[y]

		for x = 1, #srcRow do
			-- stencilData中非零的存在，在srcData中为0
			if stencilRow[x] ~= 0 then
				srcRow[x] = 3
			end
		end
	end

	return srcData
end

local GRID_SIZE = 10
function Tools.w2g(wx, wy)
	local gx = math.floor(wx / GRID_SIZE) + 1
	local gy = math.floor(wy / GRID_SIZE) + 1

	return gx, gy
end

function Tools.g2w(gx, gy)
	return (gx - 1) * GRID_SIZE, (gy - 1) * GRID_SIZE
end

function Tools.isInGrid(gridData, gx, gy)
	return gy >= 1 and gy <= #gridData and gx >= 1 and gx <= #gridData[1]
end

function Tools.dumpGrid(gridData)
	for y = #gridData, 1, -1 do
		print(table.concat(gridData[y]))
	end
end

function Tools.serializeTable(originTable)
	-- print("serializeTable")
	-- dump(originTable)
	local buffer = {}

	buffer[#buffer + 1] = "return "

	local function _serialize(t, buffer)
		buffer[#buffer + 1] = "{"

		for k, v in pairs(t) do
			buffer[#buffer + 1] = "["
			if type(k) == "number" then
				buffer[#buffer + 1] = k

			elseif type(k) == "string" then
				buffer[#buffer + 1] = "'"
				buffer[#buffer + 1] = k
				buffer[#buffer + 1] = "'"

			elseif type(k) == "table" then
				_serialize(k, buffer)

			elseif type(k) == "boolean" then
				buffer[#buffer + 1] = tostring(k)
			end

			buffer[#buffer + 1] = "]"

			buffer[#buffer + 1] = "="

			if type(v) == "number" then
				buffer[#buffer + 1] = v

			elseif type(v) == "string" then
				buffer[#buffer + 1] = "'"
				buffer[#buffer + 1] = v
				buffer[#buffer + 1] = "'"

			elseif type(v) == "table" then
				_serialize(v, buffer)

			elseif type(v) == "boolean" then
				buffer[#buffer + 1] = tostring(v)
			end

			buffer[#buffer + 1] = ","
		end

		buffer[#buffer + 1] = "}"
	end

	_serialize(originTable, buffer)

	return table.concat(buffer)
end

function Tools.deserializeTable(text)
	if not text then return nil end

	-- print("deserializeTable", text)
	local func = loadstring(text)
	-- print("func", tostring(func))
	if func then
		return func()
	end
	return nil
end

function Tools.dumpBuffer(s)
    if(s == nil) then
        return nil
    end

    local idx = 0
    local count = 0
    local result = {}
    local table_insert = table.insert
    local string_sub = string.sub
    local string_format = string.format
    for idx = 1,#s do

        table_insert(result,string_format("%02X ",string.byte(string_sub(s,idx,idx+1))))

        count = count + 1
        if count == 8 then
            table_insert(result,"   ")
        elseif count ==16 then
            table_insert(result,"\n")
            count = 0
        end
    end
    if count>0 then
        table_insert(result,"\n")
    end
    s = table.concat(result)
    return s
end

--- 计算缩放值
-- @param sw 原尺寸宽
-- @param sh 原尺寸高
-- @param tw 目标尺寸宽
-- @param th 目标尺寸高
function Tools.calcScale(sw, sh, tw, th)
	local sx = tw / sw
	local sh = th / sh

	-- 使用缩放值更小的
	return math.min(sx, sh)
end








------ 排序相关 -----
--- key值快速排序基础函数,不应对外开放
local function _quickSortBase(p)
    if p == nil or p.h >= p.t then return end

    local head,tail
    head = p.h
    tail = p.t
    local key = p.ka[head]
    local left,right
    
    left,right = head,tail
    
    while left < right do
        while (left <right) and p.f(p.a[p.ka[right]],p.a[key]) >= 0 do
            right = right - 1
        end
        p.ka[left] = p.ka[right]
        
    
        while (left < right) and p.f(p.a[p.ka[left]] ,p.a[key]) < 0 do
            left = left + 1
        end
        p.ka[right] = p.ka[left]
    end
    p.ka[left] = key


    p.h = head
    p.t = left - 1
    _quickSortBase(p)
    p.h = left + 1
    p.t = tail
    _quickSortBase(p)
end 

--- 快速排序算法
-- 本算法适用于key为连续整数的table排序,会【直接修改】原table中的元素位置
-- @param a 需要排序的表
-- @param head 表中需要排序的下标起始位置
-- @param tail 表中需要排序的下标终止位置
-- @param 比较函数 比较函数,格式为 function(v1,v2)的形式,返回值 <0 v1排在v2前; >0 v1排在v2后; =0 v1,v2相等
local function _quickSort( a, head, tail, f )
    if head >= tail then
        return
    end

    local key = a[head]
    local left,right
    
    left,right = head,tail
    
    while left < right do
        while (left <right) and f(a[right],key) >= 0 do
            right = right - 1
        end
        a[left] = a[right]
        
    
        while (left < right) and f(a[left] ,key) < 0 do
            left = left + 1
        end
        a[right] = a[left]
    end
    a[left] = key

    _quickSort( a, head, left - 1, f )
    _quickSort( a, left + 1,tail, f )
end

local function _quickSort2(a,f)
    local ka = {}
    for k, v in pairs( a ) do
        table.insert( ka, k )
    end
    local p = {}
    p.a = a
    p.ka = ka
    p.h = 1
    p.t = table.getn(ka)
    p.f = f
    _quickSortBase(p)
    return ka
end

--- 针对element进行排序
function Tools.sortArrayByField( array, fields )
	-- 重载，允许只有一个字符串
	if type( fields ) == "string" then
		fields = { fields }
	end

	-- 处理一次fields
	local fieldConfig = {}
	for k, v in pairs( fields ) do
		if string.sub( v, 1, 1 ) == "-" then
			table.insert( fieldConfig, { string.sub( v, 2, string.len( v ) ), true } )
		else
			table.insert( fieldConfig, { v, false } )
		end
	end


	-- 按照优先级进行排序
	local sorter = function( a, b )
		local ret = 0

		for k, v in pairs( fieldConfig ) do
			local field, desc = v[1], v[2]

			local v1, v2 = a[field], b[field]
			if v1 then
				if desc then
					ret = v2 - v1
				else
					ret = v1- v2
				end

				if ret ~= 0 then
					return ret
				end
			end
		end
		return ret
	end

	local sortd = {}
	local keys = _quickSort2( array, sorter )

	for k, v in pairs( keys ) do
		table.insert( sortd, array[ v ] )
	end

	return sortd
end

--- 将一个图片拷贝到可写目录
-- 目前来看这个方法用于将icon拷贝到可写目录，提供微信分享用
function Tools.copyImageToWritablePath(srcPath, dstPath)
	if device.platform == "android" then
		-- android上无法采用io.open的方式读取apk中的文件
		local image = cc.Image:new()
		local bSuccess = image:initWithImageFile(srcPath)
		if bSuccess then
			image:saveToFile(dstPath)
		end

		return bSuccess

	else
		local fullPathForFilename = cc.FileUtils:getInstance():fullPathForFilename(srcPath)
		release_print("fullPathForFilename", fullPathForFilename)
		local file = io.open(fullPathForFilename, "rb")
		if not file then
			release_print("  file not found")
			return false
		end

		local data = file:read("*a")
		file:close()

		local wFile = io.open(dstPath, "wb")
		if not wFile then
			return false
		end

		wFile:write(data)
		wFile:close()

		return true
	end
end

return Tools