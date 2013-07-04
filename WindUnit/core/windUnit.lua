


-- 单元测试开关
-- 设置为fals后，测试相关的方法将不会定义，节省内存
UNIT_TEST = true

if not UNIT_TEST then return end


-- 是否显示错误堆栈信息
UNIT_SHOW_TRACEBACK = false

-- 是否显示PASS的任务
UNIT_SHOW_PASS_TEST = true

-- 出错就停止
UNIT_BREAK_WHEN_FAILD = true



-- 引入资源 
require( "core/lemock" )
require( "core/asserts" )
require( "core/testCase" )





-- 测试组
TEST_GROUP_DEFAULT = 1

-- 定义测试用辅助代码














local testcases = {}

local _testcase_id = 0
function gfAddTestcase( case )
	_testcase_id = _testcase_id + 1

	table.insert( testcases, case )
	case.id = _testcase_id
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

	function case:test_mock()
		local mc = lemock.controller()
		local m = mc:mock()

		m:getTime()			mc:returns( 100 )
		m:getTime()			mc:returns( 200 )
		m:getName() 		mc:returns( "name" )
		m:getName() 		mc:returns( "jack" )

		mc:replay()

		assert_equal( 100, m:getTime() )
		assert_equal( 200, m:getTime() )
		assert_equal( "name", m:getName() )
		assert_equal( "jack", m:getName() )
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
		local count = case:getTestCount()
		local success = case:run()

		if UNIT_BREAK_WHEN_FAILD then
			if success < count then break end
		end

		successCount = successCount + success
	end

	print( string.format( ">>>> Result: %s/%s <<<<", successCount, funcCount ) )
end