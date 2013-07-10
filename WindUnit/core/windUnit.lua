


-- 单元测试开关
-- 设置为fals后，测试相关的方法将不会定义，节省内存
UNIT_TEST = true

if not UNIT_TEST then return end





-- 引入资源 
require( "core/asserts" )
require( "core/testCase" )





-- 测试组
TEST_GROUP_DEFAULT = 1

-- 定义测试用辅助代码














local testcases = {}

function gfAddTestcase( case )
	table.insert( testcases, case )
end

if UNIT_TEST then
	local case = cTestcase()

	function case:test_assert()
		local a, b = 1, 2
		assert( a )
		assert( b )
		assert( a ~= b )
	end

	function case:test_pass()
	end

	function case:test_true()
		assert_true( true )
		assert_false( false )
	end

	function case:test_equal()
		assert_equal( 1, 1 )
		assert_not_equal( 1, 2 )
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