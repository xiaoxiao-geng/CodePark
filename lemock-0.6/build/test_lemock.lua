require 'lemock'
require 'class'

local mc = lemock.controller()
local m = mc:mock()

m:getName()			mc:returns( "jack" )

mc:replay()

print( m:getName() )
