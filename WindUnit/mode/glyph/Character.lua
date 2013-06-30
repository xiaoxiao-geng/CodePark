-- Character 字符

Character = class( Glyph )

function Character:draw( window )
	print( "Character:draw" )
end

function Character:intersects( point )
	if not point then return false end
	print( "Character:intersects", point.x, point.y )
end

function __testcase_character()
	local case = cTestcase()

	case.test_func = function()
		print(">> test Character func")
		local c = Character()
		c:draw()
		c:intersects( Point( 1, 1 ) )
	end

	return case
end