require 'lemock'
require 'class'

Printer = class()

function Printer:init( point )
	self.point = point
end

function Printer:say()
	print( "Printer:", self.point:getX(), self.point:getY() )
end











local mc = lemock.controller()
local p = mc:mock()

p:getX()		mc:returns( 1 )
p:getY()		mc:returns( 2 )

mc:replay()

local printer = Printer( p )
printer:say()
