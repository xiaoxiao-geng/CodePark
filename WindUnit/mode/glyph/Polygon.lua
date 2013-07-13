-- Polygon 多边形

Polygon = class( Glyph )

function Polygon:draw( window )
	print( "Polygon:draw" )
end

function Polygon:intersects( point )
	if not point then return false end
	print( "Polygon:intersects", point.x, point.y )
end

if UNIT_TEST then
	local case = cTestcase()

	case.test_mock = function()
		local mc = lemock.controller()
		local m = mc:mock()

		m.arean( mc.ANYARG, mc.ANYARG ) 			mc:returns( 9 )
		m.arean( mc.ANYARG, mc.ANYARG ) 			mc:returns( 12 )

		mc:replay()

		assert_equal( 3 * 3, m.arean( 3, 3 ), "arean 3 * 3 " )
		assert_equal( 3 * 4, m.arean( 3, 4 ), "arean 3 * 4 " )

		assert_true( false )
	end
end