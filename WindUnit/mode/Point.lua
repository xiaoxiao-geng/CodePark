Point = class()

function Point:init( x, y )
	self:set( x, y )
end

function Point:set( x, y )
	self.x = x or 0
	self.y = y or 0
end

function Point:add( x, y )
	self.x = self.x + x
	self.y = self.y + y
end



if UNIT_TEST then
	local case = cTestcase()

	local p1, p2

	function case:setup()
		p1 = Point( 1, 1 )
		p2 = Point( 2, 2 )
	end

	function case:test_point()
		assert_true( p1.x == 1 )
		assert_true( p1.y == 1 )
		assert_true( p2.x == 2 )
		assert_true( p2.y == 2 )
	end
end