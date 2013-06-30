-- Rectangle 矩形

Rectangle = class( Glyph )

function Rectangle:draw( window )
	print( "Rectangle:draw" )
end

function Rectangle:intersects( point )
	if not point then return false end
	print( "Rectangle:intersects", point.x, point.y )
end