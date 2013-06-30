local _M = {}

function _M.main()
	print( ">>>>> Begin <<<<<" )

	local poly = Polygon()
	poly:draw()
	poly:intersects( Point( 100, 100 ) )

	local rect = Rectangle()
	rect:draw()
	rect:intersects( Point( 200, 200 ) )

	local char = Character()
	char:draw()
	char:intersects( Point( 300, 300 ) )

	local row = Row()
	row:insert( poly )
	row:insert( rect )
	row:insert( char, 2 )

	row:draw()
	row:intersects( Point( 400, 400 ) )


	print( ">>>>>  End  <<<<<" )
end

function _M.__test_TestMode()
	print("do __test_TestMode")
end


function _M.testTable()
	local t = {}
	t.__funcs = {}

	setmetatable( t, { 
		__index = function( t, k )
			if t.__funcs[ k ] then
				return t.__funcs[ k ]
			else
				local p1, p2 = string.find( k, "find_" )
				if p1 == 1 then
					-- find方法 
					local methodName = string.sub( k, 6, string.len( k ) )
					local p1, p2 = string.find( methodName, "_by_" )
					if p1 and p2 then
						local name = string.sub( methodName, 1, p1 - 1 )
						local field = string.sub( methodName, p2 + 1, string.len( methodName ) )

						t.__funcs[ k ] = function( ... )
							print( "name, field", name, field, ... )
						end
					end
				else
					t.__funcs[ k ] = function( ... ) print( "this is func", k, ... ) end
				end
				
				return t.__funcs[ k ]
			end
		end
	} )

	t.find_user_by_name( "jack ")
	t.find_user_by_age( 17 )
end

return _M