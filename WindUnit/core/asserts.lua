-- 各种断言方法 

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

	msg = msg or "empty"

	error( string.format( "%s: %s [%s]", tostring( testName ), string.format( formatStr, unpack( args ) ), msg ) )
end

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

function fail( msg )
	failure( "fail", msg, "failure" )
end

function assert( assertion, msg )
	if not assertion then
		failure( "assert", msg, "assertion failed" )
	end
	return assertion
end

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

function assert_equal( expected, actual, msg )
	if expected ~= actual then
		failure( "assert_equal", msg, "expected %s but was %s", format_arg( expected ), format_arg( actual ) )
	end
	return actual
end

function assert_not_equal( unexpected, actual, msg )
	if unexpected == actual then
		failure( "assert_not_equal", msg, "%s not expected but was one", format_arg( unexpected ) )
	end
	return actual
end

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

function assert_error( msg, func )
	if func == nil then
		func, msg = msg, nil
	end

	local functype = type( func )
	if functype ~= "function" then
		failure( "assert_error", msg, "expected a function as last argument but was a " .. functype )
	end

	local ok, errmsg = pcall( func )
	if ok then
	failure( "assert_error", msg, "error expected but no error occurred" )
	end
end

function assert_error_match( msg, pattern, func )
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

	local ok, errmsg = pcall( func )
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