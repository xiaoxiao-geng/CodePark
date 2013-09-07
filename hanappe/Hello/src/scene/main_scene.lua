module(..., package.seeall)

function onCreate( params )
	print( "onCreate" )
end

function onStart()
	print( "onStart" )
end

function onResume()
	print( "onResume" )
end

function onPause()
	print( "onPause" )
end

function onStop()
	print( "onStop" )
end

function onDestory()
	print( "onDestory" )
end

local frameCount = 0 
function onEnterFrame()
	frameCount = frameCount + 1
	print( "onEnterFrame", frameCount )
end
