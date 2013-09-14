module( ..., package.seeall )

function onCreate( params )
	local view1 = View { scene = scene }
	view1:getLayer().name = "Layer1"

	local view2 = View { scene = scene }
	view2:getLayer().name = "Layer1"

	local button1 = Button { parent = view1, pos = { 100, 100 }, text = "view1" }
	local button2 = Button { parent = view2, pos = { 200, 110 }, text = "view2" }
end