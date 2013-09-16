module( ..., package.seeall )

function onCreate( params )
	view = View { scene = scene }

	_G.pool = _G.pool or {}
	setmetatable( pool ,{ __mode = "v" } )

	Button { parent = view, pos = { 100, 100 }, text = "click me", onClick = onClick }

	collectgarbage()
end

function onClick()

	-- 参考 http://blog.csdn.net/bhwst/article/details/5757521
	print("begin")

	print("  loop 0")
	MOAISim.forceGarbageCollection()
	for k, v in pairs( pool ) do print( "  ", k, v ) end

	local a = "1"
	local b = "2"

	pool[ "a" ] = a
	pool[ "b" ] = b

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
