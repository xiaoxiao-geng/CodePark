module( ..., package.seeall )

function onCreate( params )
	view = View { scene = scene }

	_G.pool = _G.pool or {}
	setmetatable( pool ,{ __mode = "kv" } )

	Button { parent = view, pos = { 100, 100 }, text = "click me", onClick = onClick }

	collectgarbage()
end

function onClick()

	-- 参考 http://blog.csdn.net/bhwst/article/details/5757521
	print("begin")

	print("  loop 0")
	MOAISim.forceGarbageCollection()
	for k, v in pairs( pool ) do print( "  ", k, v ) end

	local a = { 1, 2, 3 }
	local b = { 3, 2, 1 }

	table.insert( pool, a )
	table.insert( pool, b )

	print("  loop 1")
	MOAISim.forceGarbageCollection()
	for k, v in pairs( pool ) do print( "  ", k, v ) end


	print("  loop 2")
	MOAISim.forceGarbageCollection()
	for k, v in pairs( pool ) do print( "  ", k, v ) end

	a, b = nil, nil


	print("  loop 3")
	MOAISim.forceGarbageCollection()
	for k, v in pairs( pool ) do print( "  ", k, v ) end

	print("end")
end
