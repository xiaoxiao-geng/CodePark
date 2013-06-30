-- Polygon 多边形

Polygon = class( Glyph )

function Polygon:draw( window )
	print( "Polygon:draw" )
end

function Polygon:intersects( point )
	if not point then return false end
	print( "Polygon:intersects", point.x, point.y )
end