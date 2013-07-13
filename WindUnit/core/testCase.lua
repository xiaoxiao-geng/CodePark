-- 辅助方法
local function startWith( str, startStr )
	local p1, p2 = string.find( str, startStr )
	return p1 == 1
end





-- 测试用例class
cTestcase = class()

function cTestcase:init( groupId )
	self.groupId = groupId or TEST_GROUP_DEFAULT

	gfAddTestcase( self )
end

-- 初始化，在每个测试前调用
function cTestcase:setup()
end

-- 释放，在每个测试后调用
function cTestcase:teardown()
end

-- 返回当前用例的测试数量
function cTestcase:getTestCount()
	return #self:_getTestFuncs()
end

-- 返回当前用例的所有测试方法：以test_开头的所有方法
function cTestcase:_getTestFuncs()
	local testFuncs = {}
	for k, v in pairs( self ) do
		if v and type( v ) == "function" and startWith( k, "test_" ) then
			table.insert( testFuncs, { ["name"] = k, ["func"] = v } )
		end
	end
	return testFuncs
end

-- 运行测试
-- 返回成功的数量
function cTestcase:run()
	local successCount = 0

	-- 查找自身所有 test_ 开头的方法
	local testFuncs = self:_getTestFuncs()

	-- 依次执行 
	for k, v in pairs( testFuncs ) do
		local name, func = v.name, v.func

		self:setup()
		local success, err = pcall( func, self )
		self:teardown()

		if success then 
			successCount = successCount + 1
		else
			print("case" .. self.id .. " error:", name )
			if err and type( err ) == "table" then
				local tip = err.tip or ""
				local msg = err.msg or ""
				local tb = err.traceback or {}
				local tbText = ""

				if UNIT_SHOW_TRACEBACK then tbText = traceback_to_str( tb )
				else tbText = "\n\t" .. tostring( tb[ 1 ] or "" ) end

				print( string.format( "r\t%s [%s]%s", tip, msg, tbText ) )
			else
				print("\terr:", err)
			end
			print()

			if UNIT_BREAK_WHEN_FAILD then return successCount end
		end

		-- if not r then print( "faild!!!", r ) print( debug.traceback() ) end
	end

	if UNIT_SHOW_PASS_TEST then
		if successCount == self:getTestCount() then
			print( "case" .. self.id .. " all pass test" )
		end
	end

	return successCount
end