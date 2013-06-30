-- Row 行

Row = class( Glyph )

function Row:init()
	self.children = {}
end

function Row:draw( window )
	print( "Row:draw" )

	for k, v in pairs( self.children ) do
		v:draw( window )
	end
end

function Row:intersects( point )
	if not point then return false end
	print( "Row:intersects", point.x, point.y )

	for k, v in pairs( self.children ) do
		v:intersects( point )
	end
end

function Row:insert( glyph, i )
	if not glyph then return end

	table.insert( self.children, i or 1, glyph )
end