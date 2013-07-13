require( "lemock" )

local mc =  lemock.controller()
local m = mc:mock()

m.a()			mc:returns( 1 )
m.a()			mc:returns( 2 )

mc:replay()

print( m.a() )
print( m.a() )
