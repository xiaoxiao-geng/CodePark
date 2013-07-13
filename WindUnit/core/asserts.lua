-- 各种断言方法 


local string_format   	= string.format
local _tb_hide			= {}  

function traceback_hide(func)
	_tb_hide[func] = true
end

function traceback_to_str( tb )
	return "\t>> traceback:\n\t\t" .. table.concat( tb, "\n\t\t" )
end

function customTraceback()
	local tb = {}

	local i = 2
	while true do
		local info = debug.getinfo(i, "Snlf")
		if not info or type(info) ~= "table" then break end


		if not _tb_hide[info.func] then
			local line = {}       -- Ripped from ldblib.c...
			line[#line+1] = string_format("%s:", info.short_src)

			if info.currentline > 0 then
				line[#line+1] = string_format("%d:", info.currentline)
			end

			if info.namewhat ~= "" then
				line[#line+1] = string_format(" in function '%s'", info.name)
			else
				if info.what == "main" then
					line[#line+1] = " in main chunk"
				elseif info.what == "C" or info.what == "tail" then
					line[#line+1] = " ?"
				else
					line[#line+1] = string_format(" in function <%s:%d>", info.short_src, info.linedefined)
				end
			end

			tb[#tb+1] = table.concat(line)
		end
		i = i + 1
	end

	return tb
end
traceback_hide( customTraceback )
traceback_hide( pcall )


-- 错误接口
-- testName:		测试方法名称
-- msg:				自定义消息
-- formatStr:		格式化字符串
-- ...:				format用参数
function failure( testName, msg, formatStr, ... )
	local args = { ... }
	for i = 1, #args do
		args[ i ] = tostring( args[ i ] )
	end

	local err = {}
	err.tip = string.format( formatStr, unpack( args ) )
	err.msg = msg or "empty"
	err.traceback = customTraceback()

	error( err )
end
traceback_hide( failure )

local function format_arg( arg )
	local argtype = type( arg )
	if argtype == "string" then
		return "'"..arg.."'"
	elseif argtype == "number" or argtype == "boolean" or argtype == "nil" then
		return tostring( arg )
	else
		return "["..tostring( arg ).."]"
	end
end
traceback_hide( format_arg )









function fail( msg )
	failure( "fail", msg, "failure" )
end
traceback_hide( fail )

function assert( assertion, msg )
	if not assertion then
		failure( "assert", msg, "assertion failed" )
	end
	return assertion
end
traceback_hide( assert )

function assert_true( actual, msg )
	local actualtype = type(actual)
	if actualtype ~= "boolean" then
		failure( "assert_true", msg, "true expected but was a "..actualtype )
	end
	if actual ~= true then
		failure( "assert_true", msg, "true expected but was false" )
	end
	return actual
end
traceback_hide( assert_true )

function assert_false( actual, msg )
	local actualtype = type(actual)
	if actualtype ~= "boolean" then
		failure( "assert_false", msg, "false expected but was a "..actualtype )
	end
	if actual ~= false then
		failure( "assert_false", msg, "false expected but was true" )
	end
	return actual
end
traceback_hide( assert_false )

function assert_equal( expected, actual, msg )
	if expected ~= actual then
		failure( "assert_equal", msg, "expected %s but was %s", format_arg( expected ), format_arg( actual ) )
	end
	return actual
end
traceback_hide( assert_equal )

function assert_not_equal( unexpected, actual, msg )
	if unexpected == actual then
		failure( "assert_not_equal", msg, "%s not expected but was one", format_arg( unexpected ) )
	end
	return actual
end
traceback_hide( assert_not_equal )

function assert_match(pattern, actual, msg)
	local patterntype = type( pattern )
	if patterntype ~= "string" then
		failure( "assert_match", msg, "expected the pattern as a string but was a "..patterntype )
	end

	local actualtype = type( actual )
	if actualtype ~= "string" then
		failure( "assert_match", msg, "expected a string to match pattern '%s' but was a %s", pattern, actualtype )
	end

	if not string.find( actual, pattern ) then
		failure( "assert_match", msg, "expected '%s' to match pattern '%s' but doesn't", actual, pattern )
	end
	return actual
end
traceback_hide( assert_match )

function assert_not_match( pattern, actual, msg )
	local patterntype = type( pattern )
	if patterntype ~= "string" then
		failure( "assert_not_match", msg, "expected the pattern as a string but was a " .. patterntype )
	end

	local actualtype = type( actual )
	if actualtype ~= "string" then
		failure( "assert_not_match", msg, "expected a string to not match pattern '%s' but was a %s", pattern, actualtype )
	end

	if string.find(actual, pattern) then
		failure( "assert_not_match", msg, "expected '%s' to not match pattern '%s' but it does", actual, pattern )
	end
	return actual
end
traceback_hide( assert_not_match )

function assert_error( msg, func, ... )
	if func == nil then
		func, msg = msg, nil
	end

	local functype = type( func )
	if functype ~= "function" then
		failure( "assert_error", msg, "expected a function as last argument but was a " .. functype )
	end

	local ok, errmsg = pcall( func, ... )
	if ok then
	failure( "assert_error", msg, "error expected but no error occurred" )
	end
end
traceback_hide( assert_error )

function assert_error_match( msg, pattern, func, ... )
	if func == nil then
		msg, pattern, func = nil, msg, pattern
	end

	local patterntype = type( pattern )
	if patterntype ~= "string" then
		failure( "assert_error_match", msg, "expected the pattern as a string but was a "..patterntype )
	end

	local functype = type( func )
	if functype ~= "function" then
		failure( "assert_error_match", msg, "expected a function as last argument but was a "..functype )
	end

	local ok, errmsg = pcall( func, ... )
	if ok then
	failure( "assert_error_match", msg, "error expected but no error occurred" )
	end

	local errmsgtype = type( errmsg )
	if errmsgtype ~= "string" then
		failure( "assert_error_match", msg, "error as string expected but was a " .. errmsgtype )
	end

	if not string.find( errmsg, pattern ) then
		failure( "assert_error_match", msg, "expected error '%s' to match pattern '%s' but doesn't", errmsg, pattern )
	end
end
traceback_hide( assert_error_match )

function assert_pass( msg, func )
	stats.assertions = stats.assertions + 1
	if func == nil then
		func, msg = msg, nil
	end

	local functype = type( func )
	if functype ~= "function" then
		failure( "assert_pass", msg, "expected a function as last argument but was a %s", functype )
	end

	local ok, errmsg = pcall( func )
	if not ok then
		failure( "assert_pass", msg, "no error expected but error was: '%s'", errmsg )
	end
end
traceback_hide( assert_pass )