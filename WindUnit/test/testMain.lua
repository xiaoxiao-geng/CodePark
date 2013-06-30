-- 找到全局变量中所有以 __test开头的方法

UNIT_TEST = true

local function startWith( str, startStr )
	local p1, p2 = string.find( str, startStr )
	return p1 == 1
end

cTestcase = class()
function cTestcase:init()
end

function cTestcase:setup()
end

function cTestcase:teardown()
end

function cTestcase:runTest()
	-- 查找自身所有 test_ 开头的方法
	local testFuncs = {}
	for k, v in pairs( self ) do
		if v and type( v ) == "function" and startWith( k, "test_" ) then
			table.insert( testFuncs, v )
		end
	end

	-- 依次执行 
	for k, v in pairs( testFuncs ) do
		self:setup()
		local r = pcall( v )
		self:teardown()

		if not r then print( "faild!!!" ) end
	end
end


local find = {}
function _findTestcases( t, i, name )
	if find[ t ] then return end
	find[ t ] = true

	i = i or 1

	local space = ""
	for k = 1, i do space = space .. " " end

	for k, v in pairs( t ) do
		local type = type( v )
		if type == "function" and startWith( k, "__testcase" ) then
			table.insert( testcases, v() )

		elseif type == "table" then
			_findTestcases( v, i + 1, k )
		end
	end
end

function assEqu( exp, real )
	if exp == real then return end

	print( string.format( ">>Error<< exp:[%s] -> real:[%s]", tostring( exp ), tostring( real ) ) )
end

function beginTest()
	testcases = {}

	_findTestcases( _G )

	print("test case:")
	for k, v in pairs( testcases ) do
		print( "  ", k, v )
		v:runTest()
	end
end