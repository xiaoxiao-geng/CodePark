UNIT_TEST = true
if UNIT_TEST then

	function failure( name, msg, formatStr, ... )
		local args = { ... }
		for i = 1, #args do
			args[ i ] = tostring( args[ i ] )
		end

		msg = msg or "empty"

		error( string.format( "%s: %s [%s]", tostring( name ), string.format( formatStr, unpack( args ) ), msg ) )
	end

	function assert_equal(expected, actual, msg)
		-- stats.assertions = stats.assertions + 1
		if expected ~= actual then
			failure( "assert_equal", msg, "expected %s but was %s", expected, actual )
		end
		return actual
	end

end


TEST_GROUP_DEFAULT = 1

cTestcase = class()

local function startWith( str, startStr )
	local p1, p2 = string.find( str, startStr )
	return p1 == 1
end

function cTestcase:init( groupId )
	self.groupId = groupId or TEST_GROUP_DEFAULT

	gfAddTestcase( self )
end

function cTestcase:setup()
end

function cTestcase:teardown()
end

function cTestcase:getTestCount()
	return #self:_getTestFuncs()
end

function cTestcase:_getTestFuncs()
	local testFuncs = {}
	for k, v in pairs( self ) do
		if v and type( v ) == "function" and startWith( k, "test_" ) then
			table.insert( testFuncs, { ["name"] = k, ["func"] = v } )
		end
	end
	return testFuncs
end

function cTestcase:run()
	local successCount = 0

	-- 查找自身所有 test_ 开头的方法
	local testFuncs = self:_getTestFuncs()

	-- 依次执行 
	for k, v in pairs( testFuncs ) do
		local name, func = v.name, v.func

		self:setup()
		local success, err = pcall( func )
		self:teardown()

		if success then 
			successCount = successCount + 1
		else
			print("error:", name )
			print("  ", err )
		end

		-- if not r then print( "faild!!!", r ) print( debug.traceback() ) end
	end

	return successCount
end

local testcases = {}

function gfAddTestcase( case )
	table.insert( testcases, case )
end


function assertTrue( bool )
	if bool ~= true then
		error( "it's not true: " .. tostring( bool ) .. "-" .. type( bool ) )
	end
end

if UNIT_TEST then
	local case = cTestcase()

	function case:test_assert()
		local a, b = 1, 2
		assert( a )
		assert( b )
		assert( a == b )
	end

	function case:test_pass()
	end

	function case:test_true()
		assertTrue( true )
		assertTrue( false )
	end

	function case:test_equal()
		assert_equal( 1, 1 )
		assert_equal( 1, 2 )
	end
end

function gfRunUnitTest()
	-- 1. 按照id筛选case
	local cases = {}
	local funcCount = 0
	for k, case in pairs( testcases ) do
		if case.groupId == TEST_GROUP_DEFAULT then
			table.insert( cases, case )
			funcCount = funcCount + case:getTestCount()
		end
	end

	-- 2. 运行case
	print(">>>> Run Test <<<<")
	local successCount = 0
	for k, case in pairs( cases ) do
		successCount = successCount + case:run()
	end

	print( string.format( ">>>> Result: %s/%s <<<<", successCount, funcCount ) )
end